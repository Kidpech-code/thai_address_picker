import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/thai_address.dart';
import '../models/province.dart';
import '../models/district.dart';
import '../models/sub_district.dart';
import '../models/thai_address_labels.dart';
import '../providers/thai_address_providers.dart';
import 'zip_code_autocomplete.dart';

/// A complete Thai address form with 4 fields
class ThaiAddressForm extends ConsumerStatefulWidget {
  /// Callback when address selection changes
  final void Function(ThaiAddress address)? onChanged;

  /// Custom decoration for province field
  final InputDecoration? provinceDecoration;

  /// Custom decoration for district field
  final InputDecoration? districtDecoration;

  /// Custom decoration for subdistrict field
  final InputDecoration? subDistrictDecoration;

  /// Custom decoration for zip code field
  final InputDecoration? zipCodeDecoration;

  /// Text style for all fields
  final TextStyle? textStyle;

  /// Enable/disable fields
  final bool enabled;

  /// Initial province
  final Province? initialProvince;

  /// Initial district
  final District? initialDistrict;

  /// Initial subdistrict
  final SubDistrict? initialSubDistrict;

  /// Show labels in Thai or English
  final bool useThai;

  /// Custom labels for all fields (overrides useThai defaults)
  final ThaiAddressLabels? labels;

  const ThaiAddressForm({
    super.key,
    this.onChanged,
    this.provinceDecoration,
    this.districtDecoration,
    this.subDistrictDecoration,
    this.zipCodeDecoration,
    this.textStyle,
    this.enabled = true,
    this.initialProvince,
    this.initialDistrict,
    this.initialSubDistrict,
    this.useThai = true,
    this.labels,
  });

  @override
  ConsumerState<ThaiAddressForm> createState() => _ThaiAddressFormState();
}

class _ThaiAddressFormState extends ConsumerState<ThaiAddressForm> {
  final TextEditingController _zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set initial values if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialProvince != null) {
        ref
            .read(thaiAddressNotifierProvider.notifier)
            .selectProvince(widget.initialProvince);
      }
      if (widget.initialDistrict != null) {
        ref
            .read(thaiAddressNotifierProvider.notifier)
            .selectDistrict(widget.initialDistrict);
      }
      if (widget.initialSubDistrict != null) {
        ref
            .read(thaiAddressNotifierProvider.notifier)
            .selectSubDistrict(widget.initialSubDistrict);
        _zipCodeController.text = widget.initialSubDistrict!.zipCode;
      }
    });
  }

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final state = ref.read(thaiAddressNotifierProvider);
    widget.onChanged?.call(state.toThaiAddress());
  }

  @override
  Widget build(BuildContext context) {
    // Wait for repository to initialize
    final initAsync = ref.watch(repositoryInitProvider);

    return initAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading data: $error')),
      data: (_) => _buildForm(),
    );
  }

  Widget _buildForm() {
    final state = ref.watch(thaiAddressNotifierProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);
    final provinces = notifier.getAllProvinces();
    final districts = notifier.getAvailableDistricts();
    final subDistricts = notifier.getAvailableSubDistricts();
    final effectiveLabels =
        widget.labels ??
        (widget.useThai ? ThaiAddressLabels.thai : ThaiAddressLabels.english);

    // Update zip code controller when state changes
    if (state.zipCode != null && _zipCodeController.text != state.zipCode) {
      _zipCodeController.text = state.zipCode!;
    } else if (state.zipCode == null && _zipCodeController.text.isNotEmpty) {
      _zipCodeController.clear();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Province Dropdown
        // ignore: deprecated_member_use
        DropdownButtonFormField<Province>(
          value: state.selectedProvince,
          decoration:
              widget.provinceDecoration ??
              InputDecoration(
                labelText: effectiveLabels.getProvinceLabel(widget.useThai),
                border: const OutlineInputBorder(),
              ),
          style: widget.textStyle,
          isExpanded: true,
          items: provinces.map((province) {
            return DropdownMenuItem(
              value: province,
              child: Text(
                widget.useThai ? province.nameTh : province.nameEn,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: widget.enabled
              ? (province) {
                  notifier.selectProvince(province);
                  _notifyChange();
                }
              : null,
        ),
        const SizedBox(height: 16),

        // District Dropdown
        // ignore: deprecated_member_use
        DropdownButtonFormField<District>(
          value: state.selectedDistrict,
          decoration:
              widget.districtDecoration ??
              InputDecoration(
                labelText: effectiveLabels.getDistrictLabel(widget.useThai),
                border: const OutlineInputBorder(),
              ),
          style: widget.textStyle,
          isExpanded: true,
          items: districts.map((district) {
            return DropdownMenuItem(
              value: district,
              child: Text(
                widget.useThai ? district.nameTh : district.nameEn,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: widget.enabled && state.selectedProvince != null
              ? (district) {
                  notifier.selectDistrict(district);
                  _notifyChange();
                }
              : null,
        ),
        const SizedBox(height: 16),

        // SubDistrict Dropdown
        // ignore: deprecated_member_use
        DropdownButtonFormField<SubDistrict>(
          value: state.selectedSubDistrict,
          decoration:
              widget.subDistrictDecoration ??
              InputDecoration(
                labelText: effectiveLabels.getSubDistrictLabel(widget.useThai),
                border: const OutlineInputBorder(),
              ),
          style: widget.textStyle,
          isExpanded: true,
          items: subDistricts.map((subDistrict) {
            return DropdownMenuItem(
              value: subDistrict,
              child: Text(
                widget.useThai ? subDistrict.nameTh : subDistrict.nameEn,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: widget.enabled && state.selectedDistrict != null
              ? (subDistrict) {
                  notifier.selectSubDistrict(subDistrict);
                  _notifyChange();
                }
              : null,
        ),
        const SizedBox(height: 16),

        // Zip Code Autocomplete with Smart Suggestions
        ZipCodeAutocomplete(
          controller: _zipCodeController,
          decoration:
              widget.zipCodeDecoration ??
              InputDecoration(
                labelText: effectiveLabels.getZipCodeLabel(widget.useThai),
                hintText: effectiveLabels.getZipCodeHint(widget.useThai),
                helperText: effectiveLabels.getZipCodeHelper(widget.useThai),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.local_post_office),
                errorText: state.error,
              ),
          enabled: widget.enabled,
          onZipCodeSelected: (zipCode) {
            _notifyChange();
          },
        ),
      ],
    );
  }
}
