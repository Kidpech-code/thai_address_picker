import 'package:flutter/material.dart';
import '../contracts/i_thai_address_repository.dart';
import '../models/suggestions.dart';
import '../models/thai_address_labels.dart';

/// Pure-Flutter village autocomplete widget.
///
/// **No Riverpod, BLoC, or any state-management library is required.**
///
/// Supply an [IThaiAddressRepository] directly.  Village data is loaded lazily
/// by the repository, so this widget works without any upfront cost.
///
/// ```dart
/// VillageAutocomplete(
///   repository: myRepository,
///   onSuggestionSelected: (suggestion) {
///     print('Village: ${suggestion.village.nameTh}');
///   },
/// )
/// ```
///
/// When this widget is embedded inside [ThaiAddressForm], callbacks are wired
/// to the [ThaiAddressController] automatically.
class VillageAutocomplete extends StatefulWidget {
  /// The data source used to query village suggestions (loaded lazily).
  final IThaiAddressRepository repository;

  /// External [TextEditingController].  If omitted an internal one is created.
  final TextEditingController? controller;

  /// Decoration applied to the underlying [TextField].
  final InputDecoration? decoration;

  /// Called when the user selects a suggestion from the dropdown.
  final ValueChanged<VillageSuggestion>? onSuggestionSelected;

  /// Maximum number of dropdown suggestions (default 20).
  final int maxSuggestions;

  final bool enabled;
  final bool useThai;
  final ThaiAddressLabels? labels;

  const VillageAutocomplete({
    super.key,
    required this.repository,
    this.controller,
    this.decoration,
    this.onSuggestionSelected,
    this.maxSuggestions = 20,
    this.enabled = true,
    this.useThai = true,
    this.labels,
  });

  @override
  State<VillageAutocomplete> createState() => _VillageAutocompleteState();
}

class _VillageAutocompleteState extends State<VillageAutocomplete> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _internalController = true;
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_internalController) _controller.dispose();
    super.dispose();
  }

  ThaiAddressLabels get _labels =>
      widget.labels ??
      (widget.useThai ? ThaiAddressLabels.thai : ThaiAddressLabels.english);

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<VillageSuggestion>(
      focusNode: _focusNode,
      textEditingController: _controller,
      // optionsBuilder accepts FutureOr<Iterable> — the Future path is used
      // here since village data may still be loading.
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) {
          return const Iterable<VillageSuggestion>.empty();
        }
        return widget.repository.searchVillages(
          value.text,
          maxResults: widget.maxSuggestions,
        );
      },
      displayStringForOption: (s) => s.village.nameTh,
      fieldViewBuilder:
          (
            BuildContext ctx,
            TextEditingController textCtrl,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextField(
              controller: textCtrl,
              focusNode: focusNode,
              enabled: widget.enabled,
              decoration:
                  widget.decoration ??
                  InputDecoration(
                    labelText: _labels.getVillageLabel(widget.useThai),
                    hintText: _labels.getVillageHint(widget.useThai),
                    helperText: _labels.getVillageHelper(widget.useThai),
                    prefixIcon: const Icon(Icons.home),
                  ),
              keyboardType: TextInputType.text,
            );
          },
      optionsViewBuilder:
          (
            BuildContext ctx,
            AutocompleteOnSelected<VillageSuggestion> onSelected,
            Iterable<VillageSuggestion> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                    maxWidth: 400,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (_, int i) {
                      final s = options.elementAt(i);
                      return ListTile(
                        dense: true,
                        leading: s.displayMoo.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: Theme.of(
                                    ctx,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  s.displayMoo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(ctx).primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : null,
                        title: Text(
                          s.displayText,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: s.subDistrict?.zipCode != null
                            ? Text(
                                'รหัสไปรษณีย์: ${s.subDistrict!.zipCode}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : null,
                        onTap: () => onSelected(s),
                      );
                    },
                  ),
                ),
              ),
            );
          },
      onSelected: (VillageSuggestion suggestion) {
        _controller.text = suggestion.village.nameTh;
        widget.onSuggestionSelected?.call(suggestion);
      },
    );
  }
}
