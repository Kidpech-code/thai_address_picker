import 'package:flutter/material.dart';
import '../controllers/thai_address_controller.dart';
import '../models/thai_address.dart';
import '../models/province.dart';
import '../models/district.dart';
import '../models/sub_district.dart';
import '../models/thai_address_labels.dart';
import '../models/suggestions.dart';
import 'zip_code_autocomplete.dart';

/// A complete Thai address form with Province → District → Sub-district →
/// Zip Code drop-downs.
///
/// **Zero dependency on Riverpod or any other state-management library.**
///
/// The form is driven entirely by a [ThaiAddressController] — the same
/// ergonomic pattern as Flutter's own [TextEditingController]:
///
/// ```dart
/// // 1. Create once (ideally in State.initState or a DI container)
/// late final _controller = ThaiAddressController(
///   repository: ThaiAddressRepository(),
/// );
///
/// @override
/// void initState() {
///   super.initState();
///   _controller.initialize(); // kicks off asset loading
/// }
///
/// @override
/// void dispose() {
///   _controller.dispose();
///   super.dispose();
/// }
///
/// // 2. Drop into your widget tree
/// ThaiAddressForm(
///   controller: _controller,
///   onChanged: (address) => print(address.provinceTh),
/// )
///
/// // 3. Read the value at submit time
/// final address = _controller.toThaiAddress();
/// ```
///
/// ### Loading state
/// While the repository is initialising, the form shows a centred
/// [CircularProgressIndicator].  Once ready, fields become interactive.
///
/// ### Cascading selection
/// Selecting a province clears the district, sub-district, and zip code.
/// Selecting a sub-district auto-fills the zip code.
/// Entering a 5-digit zip code performs a reverse lookup.
class ThaiAddressForm extends StatefulWidget {
  /// Controller that owns the selection state and provides data queries.
  final ThaiAddressController controller;

  /// Called whenever the address selection changes.
  final void Function(ThaiAddress address)? onChanged;

  /// Custom decoration for each field (overrides default outlined style).
  final InputDecoration? provinceDecoration;
  final InputDecoration? districtDecoration;
  final InputDecoration? subDistrictDecoration;
  final InputDecoration? zipCodeDecoration;

  /// Text style applied to all dropdown items.
  final TextStyle? textStyle;

  /// When `false` all fields are disabled.
  final bool enabled;

  /// Use Thai labels (`true`, default) or English labels (`false`).
  final bool useThai;

  /// Custom localized labels — overrides [useThai] when provided.
  final ThaiAddressLabels? labels;

  /// Show the zip-code autocomplete with suggestions (default `true`).
  /// Set to `false` to show a plain [TextField] instead.
  final bool showZipCodeAutocomplete;

  const ThaiAddressForm({
    super.key,
    required this.controller,
    this.onChanged,
    this.provinceDecoration,
    this.districtDecoration,
    this.subDistrictDecoration,
    this.zipCodeDecoration,
    this.textStyle,
    this.enabled = true,
    this.useThai = true,
    this.labels,
    this.showZipCodeAutocomplete = true,
  });

  @override
  State<ThaiAddressForm> createState() => _ThaiAddressFormState();
}

class _ThaiAddressFormState extends State<ThaiAddressForm> {
  final TextEditingController _zipController = TextEditingController();
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = widget.controller.initialize();
    widget.controller.addListener(_onControllerChanged);
  }

  /// Keeps _zipController in sync whenever the controller's state changes.
  void _onControllerChanged() {
    final zip = widget.controller.value.zipCode ?? '';
    if (_zipController.text != zip) {
      _zipController.text = zip;
    }
  }

  @override
  void didUpdateWidget(ThaiAddressForm old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onControllerChanged);
      _initFuture = widget.controller.initialize();
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _zipController.dispose();
    super.dispose();
  }

  ThaiAddressLabels get _effectiveLabels =>
      widget.labels ??
      (widget.useThai ? ThaiAddressLabels.thai : ThaiAddressLabels.english);

  void _notifyChanged() {
    widget.onChanged?.call(widget.controller.toThaiAddress());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data: ${snapshot.error}'));
        }
        return ValueListenableBuilder<ThaiAddressSelection>(
          valueListenable: widget.controller,
          builder: (context, selection, _) => _buildForm(selection),
        );
      },
    );
  }

  Widget _buildForm(ThaiAddressSelection selection) {
    final ctrl = widget.controller;
    final provinces = ctrl.getAllProvinces();
    final districts = ctrl.getAvailableDistricts();
    final subDistricts = ctrl.getAvailableSubDistricts();
    final labels = _effectiveLabels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Province ─────────────────────────────────────────────────────
        // ignore: deprecated_member_use
        DropdownButtonFormField<Province>(
          value: selection.province,
          decoration:
              widget.provinceDecoration ??
              InputDecoration(
                labelText: labels.getProvinceLabel(widget.useThai),
                border: const OutlineInputBorder(),
              ),
          style: widget.textStyle,
          isExpanded: true,
          items: provinces
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    widget.useThai ? p.nameTh : p.nameEn,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: widget.enabled
              ? (p) {
                  ctrl.selectProvince(p);
                  _notifyChanged();
                }
              : null,
        ),
        const SizedBox(height: 16),

        // ── District ─────────────────────────────────────────────────────
        // ignore: deprecated_member_use
        DropdownButtonFormField<District>(
          value: selection.district,
          decoration:
              widget.districtDecoration ??
              InputDecoration(
                labelText: labels.getDistrictLabel(widget.useThai),
                border: const OutlineInputBorder(),
              ),
          style: widget.textStyle,
          isExpanded: true,
          items: districts
              .map(
                (d) => DropdownMenuItem(
                  value: d,
                  child: Text(
                    widget.useThai ? d.nameTh : d.nameEn,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: widget.enabled && selection.province != null
              ? (d) {
                  ctrl.selectDistrict(d);
                  _notifyChanged();
                }
              : null,
        ),
        const SizedBox(height: 16),

        // ── Sub-district ──────────────────────────────────────────────────
        // ignore: deprecated_member_use
        DropdownButtonFormField<SubDistrict>(
          value: selection.subDistrict,
          decoration:
              widget.subDistrictDecoration ??
              InputDecoration(
                labelText: labels.getSubDistrictLabel(widget.useThai),
                border: const OutlineInputBorder(),
              ),
          style: widget.textStyle,
          isExpanded: true,
          items: subDistricts
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    widget.useThai ? s.nameTh : s.nameEn,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: widget.enabled && selection.district != null
              ? (s) {
                  ctrl.selectSubDistrict(s);
                  _notifyChanged();
                }
              : null,
        ),
        const SizedBox(height: 16),

        // ── Zip code (autocomplete or plain text) ─────────────────────────
        if (widget.showZipCodeAutocomplete)
          ZipCodeAutocomplete(
            repository: ctrl.repository,
            controller: _zipController,
            decoration:
                widget.zipCodeDecoration ??
                InputDecoration(
                  labelText: labels.getZipCodeLabel(widget.useThai),
                  hintText: labels.getZipCodeHint(widget.useThai),
                  helperText: labels.getZipCodeHelper(widget.useThai),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.local_post_office),
                  errorText: selection.error,
                ),
            enabled: widget.enabled,
            useThai: widget.useThai,
            labels: widget.labels,
            onZipCodeChanged: (zip) {
              ctrl.setZipCode(zip);
              _notifyChanged();
            },
            onSuggestionSelected: (ZipCodeSuggestion suggestion) {
              ctrl.selectZipCodeSuggestion(suggestion);
              _notifyChanged();
            },
            onCleared: () {
              ctrl.clearZipCode();
              _notifyChanged();
            },
          )
        else
          TextField(
            controller: _zipController,
            decoration:
                widget.zipCodeDecoration ??
                InputDecoration(
                  labelText: labels.getZipCodeLabel(widget.useThai),
                  hintText: labels.getZipCodeHint(widget.useThai),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.local_post_office),
                  errorText: selection.error,
                ),
            keyboardType: TextInputType.number,
            maxLength: 5,
            enabled: widget.enabled,
            onChanged: (v) {
              if (v.isNotEmpty) {
                ctrl.setZipCode(v);
              } else {
                ctrl.clearZipCode();
              }
              _notifyChanged();
            },
          ),
      ],
    );
  }
}
