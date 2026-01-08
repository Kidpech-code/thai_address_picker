import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/thai_address_repository.dart';
import '../providers/thai_address_providers.dart';
import '../models/thai_address_labels.dart';

/// High-performance Zip Code Autocomplete Widget
///
/// Provides real-time autocomplete for Thai zip codes with:
/// - **Instant suggestions** from first digit typed
/// - **Prefix matching** for accurate results (e.g., "102" matches 10200, 10210)
/// - **Full address preview** in dropdown (Zip • SubDistrict • District • Province)
/// - **Multi-area handling** for zip codes with multiple locations
/// - **Auto-fill cascade** when suggestion is selected
///
/// Performance:
/// - O(k) search complexity where k = [maxSuggestions] (default: 20)
/// - Early exit optimization for fast response
/// - No blocking operations, runs on UI thread efficiently
///
/// Usage:
/// ```dart
/// ZipCodeAutocomplete(
///   decoration: InputDecoration(labelText: 'Zip Code'),
///   onZipCodeSelected: (zip) => print('Selected: $zip'),
/// )
/// ```
///
/// Features:
/// - Real-time search without debouncing (optimized for performance)
/// - Prefix matching for accurate suggestions
/// - Shows full address hierarchy (ZipCode → SubDistrict → District → Province)
/// - Handles multiple areas with same zip code
/// - O(k) search with early exit optimization where k = maxSuggestions
class ZipCodeAutocomplete extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final ValueChanged<String>? onZipCodeSelected;
  final int maxSuggestions;
  final bool enabled;
  final bool useThai;
  final ThaiAddressLabels? labels;

  const ZipCodeAutocomplete({
    super.key,
    this.controller,
    this.decoration,
    this.onZipCodeSelected,
    this.maxSuggestions = 20,
    this.enabled = true,
    this.useThai = true,
    this.labels,
  });

  @override
  ConsumerState<ZipCodeAutocomplete> createState() =>
      _ZipCodeAutocompleteState();
}

class _ZipCodeAutocompleteState extends ConsumerState<ZipCodeAutocomplete> {
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
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    return RawAutocomplete<ZipCodeSuggestion>(
      focusNode: _focusNode,
      textEditingController: _controller,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text;

        // Return empty if query is empty or not numeric
        if (query.isEmpty || !RegExp(r'^\d+$').hasMatch(query)) {
          return const Iterable<ZipCodeSuggestion>.empty();
        }

        // Search with max results limit for performance
        final suggestions = notifier.searchZipCodes(
          query,
          maxResults: widget.maxSuggestions,
        );

        return suggestions;
      },
      displayStringForOption: (ZipCodeSuggestion suggestion) {
        return suggestion.zipCode;
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
                    labelText: effectiveLabels.getZipCodeLabel(widget.useThai),
                    hintText: effectiveLabels.getZipCodeHint(widget.useThai),
                    helperText: effectiveLabels.getZipCodeHelper(
                      widget.useThai,
                    ),
                    prefixIcon: const Icon(Icons.local_post_office),
                  ),
              keyboardType: TextInputType.number,
              maxLength: 5,
              onChanged: (value) {
                // Real-time update: trigger for any length
                // But only auto-fill when it's exactly 5 digits
                if (value.isNotEmpty) {
                  ref
                      .read(thaiAddressNotifierProvider.notifier)
                      .setZipCode(value);
                } else {
                  // Clear when empty
                  ref.read(thaiAddressNotifierProvider.notifier).reset();
                }
              },
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<ZipCodeSuggestion> onSelected,
            Iterable<ZipCodeSuggestion> options,
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
                            suggestion.zipCode,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        title: Text(
                          suggestion.displayText,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: suggestion.displayTextEn.isNotEmpty
                            ? Text(
                                suggestion.displayTextEn,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
      onSelected: (ZipCodeSuggestion suggestion) {
        // Update controller
        _controller.text = suggestion.zipCode;

        // Auto-fill all address fields
        notifier.selectZipCodeSuggestion(suggestion);

        // Callback
        widget.onZipCodeSelected?.call(suggestion.zipCode);
      },
    );
  }
}
