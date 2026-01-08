import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/thai_address_repository.dart';
import '../providers/thai_address_providers.dart';
import '../models/village.dart';
import '../models/thai_address_labels.dart';

/// High-performance Village Autocomplete Widget
///
/// Provides real-time autocomplete for Thai villages (หมู่บ้าน) with:
/// - **Instant suggestions** from first character typed
/// - **Substring matching** for flexible search (e.g., "บ้าน" matches all villages with "บ้าน")
/// - **Full address preview** in dropdown (Village • หมู่ • SubDistrict • District • Province)
/// - **Moo number display** (หมู่ที่) for accurate village identification
/// - **Auto-fill cascade** when suggestion is selected
///
/// Performance:
/// - O(k) search complexity where k = [maxSuggestions] (default: 20)
/// - Early exit optimization for fast response
/// - No blocking operations, runs on UI thread efficiently
///
/// Usage:
/// ```dart
/// VillageAutocomplete(
///   decoration: InputDecoration(labelText: 'หมู่บ้าน'),
///   onVillageSelected: (village) => print('Selected: ${village.nameTh}'),
/// )
/// ```
///
/// Features:
/// - Real-time search from first character
/// - Substring matching for Thai text
/// - Shows full address hierarchy (Village • หมู่ • SubDistrict • District • Province)
/// - Handles village name duplicates across different areas
/// - O(k) search with early exit optimization where k = maxSuggestions
class VillageAutocomplete extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final ValueChanged<Village>? onVillageSelected;
  final int maxSuggestions;
  final bool enabled;
  final bool useThai;
  final ThaiAddressLabels? labels;

  const VillageAutocomplete({
    super.key,
    this.controller,
    this.decoration,
    this.onVillageSelected,
    this.maxSuggestions = 20,
    this.enabled = true,
    this.useThai = true,
    this.labels,
  });

  @override
  ConsumerState<VillageAutocomplete> createState() =>
      _VillageAutocompleteState();
}

class _VillageAutocompleteState extends ConsumerState<VillageAutocomplete> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isControllerInternal = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isControllerInternal = true;
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_isControllerInternal) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(thaiAddressRepositoryProvider);

    return RawAutocomplete<VillageSuggestion>(
      focusNode: _focusNode,
      textEditingController: _controller,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text;

        // Return empty if query is too short (less than 1 character)
        if (query.isEmpty) {
          return const Iterable<VillageSuggestion>.empty();
        }

        // Search with max results limit for performance
        final suggestions = repository.searchVillages(
          query,
          maxResults: widget.maxSuggestions,
        );

        return suggestions;
      },
      displayStringForOption: (VillageSuggestion suggestion) {
        return suggestion.village.nameTh;
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            final effectiveLabels =
                widget.labels ??
                (widget.useThai
                    ? ThaiAddressLabels.thai
                    : ThaiAddressLabels.english);

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              enabled: widget.enabled,
              decoration:
                  widget.decoration ??
                  InputDecoration(
                    labelText: effectiveLabels.getVillageLabel(widget.useThai),
                    hintText: effectiveLabels.getVillageHint(widget.useThai),
                    helperText: effectiveLabels.getVillageHelper(
                      widget.useThai,
                    ),
                    prefixIcon: const Icon(Icons.home),
                  ),
              keyboardType: TextInputType.text,
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
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
                    itemBuilder: (BuildContext context, int index) {
                      final suggestion = options.elementAt(index);

                      return ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            suggestion.displayMoo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          suggestion.displayText,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: suggestion.subDistrict?.zipCode != null
                            ? Text(
                                'รหัสไปรษณีย์: ${suggestion.subDistrict!.zipCode}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : null,
                        onTap: () {
                          onSelected(suggestion);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
      onSelected: (VillageSuggestion suggestion) {
        // Update controller
        _controller.text = suggestion.village.nameTh;

        // Auto-fill address fields if possible
        if (suggestion.subDistrict != null) {
          final notifier = ref.read(thaiAddressNotifierProvider.notifier);
          if (suggestion.province != null) {
            notifier.selectProvince(suggestion.province);
          }
          if (suggestion.district != null) {
            notifier.selectDistrict(suggestion.district);
          }
          notifier.selectSubDistrict(suggestion.subDistrict);
        }

        // Callback
        widget.onVillageSelected?.call(suggestion.village);
      },
    );
  }
}
