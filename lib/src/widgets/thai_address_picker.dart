import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/thai_address.dart';
import 'thai_address_form.dart';

/// A picker widget that shows Thai address form in a bottom sheet or dialog
class ThaiAddressPicker {
  /// Show Thai address picker as a bottom sheet
  static Future<ThaiAddress?> showBottomSheet({
    required BuildContext context,
    ThaiAddress? initialAddress,
    bool useThai = true,
    double? height,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    ThaiAddress? selectedAddress;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _PickerContent(
        initialAddress: initialAddress,
        useThai: useThai,
        height: height,
        onConfirm: (address) {
          selectedAddress = address;
          Navigator.of(context).pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );

    return selectedAddress;
  }

  /// Show Thai address picker as a dialog
  static Future<ThaiAddress?> showDialog({
    required BuildContext context,
    ThaiAddress? initialAddress,
    bool useThai = true,
    bool barrierDismissible = true,
  }) async {
    return await showGeneralDialog<ThaiAddress>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Thai Address Picker',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: _PickerContent(
            initialAddress: initialAddress,
            useThai: useThai,
            isDialog: true,
            onConfirm: (address) {
              Navigator.of(context).pop(address);
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

class _PickerContent extends ConsumerStatefulWidget {
  final ThaiAddress? initialAddress;
  final bool useThai;
  final double? height;
  final bool isDialog;
  final Function(ThaiAddress) onConfirm;
  final VoidCallback onCancel;

  const _PickerContent({
    this.initialAddress,
    this.useThai = true,
    this.height,
    this.isDialog = false,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  ConsumerState<_PickerContent> createState() => _PickerContentState();
}

class _PickerContentState extends ConsumerState<_PickerContent> {
  ThaiAddress? _currentAddress;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final contentHeight = widget.height ?? screenHeight * 0.75;

    return Container(
      height: widget.isDialog ? null : contentHeight,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: widget.isDialog ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.useThai ? 'เลือกที่อยู่' : 'Select Address',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ThaiAddressForm(
                useThai: widget.useThai,
                onChanged: (address) {
                  _currentAddress = address;
                },
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(widget.useThai ? 'ยกเลิก' : 'Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentAddress != null) {
                        widget.onConfirm(_currentAddress!);
                      }
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(widget.useThai ? 'ยืนยัน' : 'Confirm'),
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
