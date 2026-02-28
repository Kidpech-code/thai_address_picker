import 'package:flutter/material.dart';
import '../contracts/i_thai_address_repository.dart';
import '../controllers/thai_address_controller.dart';
import '../models/thai_address.dart';
import '../models/thai_address_labels.dart';
import '../repository/thai_address_repository.dart';
import 'thai_address_form.dart';

/// Utility class that presents [ThaiAddressForm] inside a bottom sheet or
/// dialog.
///
/// **Zero dependency on Riverpod or any other state-management library.**
///
/// A [ThaiAddressController] is created internally and scoped to the lifetime
/// of the sheet / dialog.  The confirmed [ThaiAddress] is returned via the
/// `Future`.
///
/// ```dart
/// // Bottom sheet
/// final address = await ThaiAddressPicker.showBottomSheet(
///   context: context,
///   repository: myRepository, // or null to use the default singleton
/// );
///
/// // Dialog
/// final address = await ThaiAddressPicker.showDialog(context: context);
/// ```
class ThaiAddressPicker {
  ThaiAddressPicker._();

  /// Show the picker as a modal bottom sheet.
  ///
  /// Parameters:
  /// - [repository]: Data source to use.  Defaults to the singleton
  ///   [ThaiAddressRepository] when `null`.
  /// - [initialAddress]: Pre-populate fields from an existing [ThaiAddress].
  static Future<ThaiAddress?> showBottomSheet({
    required BuildContext context,
    IThaiAddressRepository? repository,
    ThaiAddress? initialAddress,
    bool useThai = true,
    ThaiAddressLabels? labels,
    double? height,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    ThaiAddress? result;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerContent(
        repository: repository ?? ThaiAddressRepository(),
        initialAddress: initialAddress,
        useThai: useThai,
        labels: labels,
        height: height,
        isDialog: false,
        onConfirm: (a) {
          result = a;
          Navigator.of(context).pop();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
    return result;
  }

  /// Show the picker as a centered dialog.
  static Future<ThaiAddress?> showDialog({
    required BuildContext context,
    IThaiAddressRepository? repository,
    ThaiAddress? initialAddress,
    bool useThai = true,
    ThaiAddressLabels? labels,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<ThaiAddress>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Thai Address Picker',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, _, __) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _PickerContent(
          repository: repository ?? ThaiAddressRepository(),
          initialAddress: initialAddress,
          useThai: useThai,
          labels: labels,
          isDialog: true,
          onConfirm: (a) => Navigator.of(ctx).pop(a),
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private picker content widget
// ---------------------------------------------------------------------------

class _PickerContent extends StatefulWidget {
  final IThaiAddressRepository repository;
  final ThaiAddress? initialAddress;
  final bool useThai;
  final ThaiAddressLabels? labels;
  final double? height;
  final bool isDialog;
  final void Function(ThaiAddress) onConfirm;
  final VoidCallback onCancel;

  const _PickerContent({
    required this.repository,
    required this.onConfirm,
    required this.onCancel,
    this.initialAddress,
    this.useThai = true,
    this.labels,
    this.height,
    this.isDialog = false,
  });

  @override
  State<_PickerContent> createState() => _PickerContentState();
}

class _PickerContentState extends State<_PickerContent> {
  late final ThaiAddressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ThaiAddressController(repository: widget.repository);
    // Seed initial address after repo is ready.
    if (widget.initialAddress != null) {
      _controller.initialize().then((_) {
        if (mounted) {
          _controller.setFromThaiAddress(widget.initialAddress!);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ThaiAddressLabels get _effectiveLabels =>
      widget.labels ??
      (widget.useThai ? ThaiAddressLabels.thai : ThaiAddressLabels.english);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final contentHeight = widget.height ?? screenHeight * 0.75;

    return Container(
      height: widget.isDialog ? null : contentHeight,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: widget.isDialog ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _effectiveLabels.getPickerTitle(widget.useThai),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ),

          // ── Form ─────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ThaiAddressForm(
                controller: _controller,
                useThai: widget.useThai,
                labels: widget.labels,
              ),
            ),
          ),

          // ── Actions ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _effectiveLabels.getCancelButton(widget.useThai),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<ThaiAddressSelection>(
                    valueListenable: _controller,
                    builder: (_, selection, __) => ElevatedButton(
                      onPressed: selection.isEmpty
                          ? null
                          : () => widget.onConfirm(_controller.toThaiAddress()),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _effectiveLabels.getConfirmButton(widget.useThai),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
