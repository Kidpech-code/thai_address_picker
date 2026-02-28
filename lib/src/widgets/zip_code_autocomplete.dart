import 'package:flutter/material.dart';
import '../contracts/i_thai_address_repository.dart';
import '../models/suggestions.dart';
import '../models/thai_address_labels.dart';

/// Pure-Flutter zip-code autocomplete widget.
///
/// **No Riverpod, BLoC, or any state-management library is required.**
///
/// Supply an [IThaiAddressRepository] directly; the widget queries it for
/// prefix-matched suggestions and exposes results through callbacks:
///
/// ```dart
/// ZipCodeAutocomplete(
///   repository: myRepository,
///   onSuggestionSelected: (suggestion) {
///     print('Selected: ${suggestion.zipCode}');
///   },
/// )
/// ```
///
/// Typically used inside [ThaiAddressForm], which wires the callbacks to its
/// [ThaiAddressController] automatically.  Can also be used standalone.
class ZipCodeAutocomplete extends StatefulWidget {
  /// The data source used to query zip-code suggestions.
  final IThaiAddressRepository repository;

  /// External [TextEditingController].  If omitted an internal one is created.
  final TextEditingController? controller;

  /// Decoration applied to the underlying [TextField].
  final InputDecoration? decoration;

  /// Called whenever the raw text changes (after every keystroke).
  final ValueChanged<String>? onZipCodeChanged;

  /// Called when the user selects a suggestion from the dropdown.
  final ValueChanged<ZipCodeSuggestion>? onSuggestionSelected;

  /// Called when the field is cleared.
  final VoidCallback? onCleared;

  /// Maximum number of dropdown suggestions (default 20).
  final int maxSuggestions;

  final bool enabled;
  final bool useThai;
  final ThaiAddressLabels? labels;

  const ZipCodeAutocomplete({
    super.key,
    required this.repository,
    this.controller,
    this.decoration,
    this.onZipCodeChanged,
    this.onSuggestionSelected,
    this.onCleared,
    this.maxSuggestions = 20,
    this.enabled = true,
    this.useThai = true,
    this.labels,
  });

  @override
  State<ZipCodeAutocomplete> createState() => _ZipCodeAutocompleteState();
}

class _ZipCodeAutocompleteState extends State<ZipCodeAutocomplete> {
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
    return RawAutocomplete<ZipCodeSuggestion>(
      focusNode: _focusNode,
      textEditingController: _controller,
      optionsBuilder: (TextEditingValue value) {
        final query = value.text;
        if (query.isEmpty || !RegExp(r'^\d+$').hasMatch(query)) {
          return const Iterable<ZipCodeSuggestion>.empty();
        }
        return widget.repository.searchZipCodes(
          query,
          maxResults: widget.maxSuggestions,
        );
      },
      displayStringForOption: (s) => s.zipCode,
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
                    labelText: _labels.getZipCodeLabel(widget.useThai),
                    hintText: _labels.getZipCodeHint(widget.useThai),
                    helperText: _labels.getZipCodeHelper(widget.useThai),
                    prefixIcon: const Icon(Icons.local_post_office),
                  ),
              keyboardType: TextInputType.number,
              maxLength: 5,
              onChanged: (v) {
                if (v.isEmpty) {
                  widget.onCleared?.call();
                } else {
                  widget.onZipCodeChanged?.call(v);
                }
              },
            );
          },
      optionsViewBuilder:
          (
            BuildContext ctx,
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
                    itemBuilder: (_, int i) {
                      final s = options.elementAt(i);
                      return ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Theme.of(ctx).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s.zipCode,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(ctx).primaryColor,
                            ),
                          ),
                        ),
                        title: Text(
                          s.displayText,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: s.displayTextEn.isNotEmpty
                            ? Text(
                                s.displayTextEn,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
      onSelected: (ZipCodeSuggestion suggestion) {
        _controller.text = suggestion.zipCode;
        widget.onSuggestionSelected?.call(suggestion);
      },
    );
  }
}
