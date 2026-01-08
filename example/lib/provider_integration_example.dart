// ตัวอย่างการใช้งาน thai_address_picker กับ Provider package
// Example: Integration with Provider state management
//
// Note: Add 'provider: ^6.0.0' to your pubspec.yaml dependencies to use this example
// This file is commented out because Provider is an optional dependency.
// Uncomment and add Provider to your project to use this integration.
//
// นี่คือ Scenario 3 จาก README - ใช้ร่วมกับ Provider/GetX/BLoC เป็นต้น

/*
import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';
import 'package:provider/provider.dart';

// ==================== State Management ====================

/// State ของหน้าฟอร์มอยู่ที่นี่
class AddressFormState extends ChangeNotifier {
  ThaiAddress? _selectedAddress;
  bool _isSubmitting = false;

  ThaiAddress? get selectedAddress => _selectedAddress;
  bool get isSubmitting => _isSubmitting;

  /// อัปเดตที่อยู่ที่เลือก
  void selectAddress(ThaiAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  /// ส่งฟอร์ม
  Future<void> submitForm() async {
    if (_selectedAddress == null) {
      throw Exception('กรุณาเลือกที่อยู่ก่อน');
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      // จำลองการส่งไป server
      await Future.delayed(const Duration(seconds: 2));

      print('✅ ส่งที่อยู่สำเร็จ:');
      print('   จังหวัด: ${_selectedAddress!.provinceTh}');
      print('   อำเภอ: ${_selectedAddress!.districtTh}');
      print('   ตำบล: ${_selectedAddress!.subDistrictTh}');
      print('   รหัสไปรษณีย์: ${_selectedAddress!.zipCode}');

      // reset
      _selectedAddress = null;
      notifyListeners();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

// ==================== Pages ====================

/// หน้าหลักของการใช้ Provider + thai_address_picker
class ProviderIntegrationExample extends StatelessWidget {
  const ProviderIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Integration Example'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ส่วน 1: คำอธิบาย
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Scenario 3: ใช้ร่วมกับ Provider',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ตัวอย่างนี้แสดงวิธีการใช้ thai_address_picker กับ Provider state management',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 Key Points:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildPoint('ProviderScope wrap app ด้านนอก'),
                      _buildPoint('Provider ใช้สำหรับ state management'),
                      _buildPoint(
                        'thai_address_picker + Provider ใช้ได้พร้อมกัน',
                      ),
                      _buildPoint(
                        'ไม่มี conflict ระหว่าง Riverpod กับ Provider',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ส่วน 2: ฟอร์ม
          _buildFormSection(context),
          const SizedBox(height: 24),

          // ส่วน 3: ข้อมูลที่เลือก
          _buildSelectedAddressSection(context),
        ],
      ),
    );
  }

  Widget _buildPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📝 Form',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // ใช้ Consumer เพื่อให้ Provider update ได้
            Consumer<AddressFormState>(
              builder: (context, addressState, _) {
                return ThaiAddressForm(
                  onChanged: (address) {
                    // ส่งข้อมูลไป Provider
                    addressState.selectAddress(address);
                  },
                  useThai: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAddressSection(BuildContext context) {
    return Consumer<AddressFormState>(
      builder: (context, addressState, _) {
        if (addressState.selectedAddress == null) {
          return const SizedBox.shrink();
        }

        final address = addressState.selectedAddress!;

        return Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ ที่อยู่ที่เลือก',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildAddressRow('จังหวัด', address.provinceTh),
                _buildAddressRow('Province', address.provinceEn),
                const SizedBox(height: 8),
                _buildAddressRow('อำเภอ/เขต', address.districtTh),
                _buildAddressRow('District', address.districtEn),
                const SizedBox(height: 8),
                _buildAddressRow('ตำบล/แขวง', address.subDistrictTh),
                _buildAddressRow('Sub-district', address.subDistrictEn),
                const SizedBox(height: 8),
                _buildAddressRow('รหัสไปรษณีย์', address.zipCode),
                if (address.lat != null)
                  _buildAddressRow('Latitude', address.lat!.toString()),
                if (address.long != null)
                  _buildAddressRow('Longitude', address.long!.toString()),
                const SizedBox(height: 16),
                // ปุ่ม Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: addressState.isSubmitting
                        ? null
                        : () async {
                            try {
                              await addressState.submitForm();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ ส่งที่อยู่สำเร็จ!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('❌ Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    child: addressState.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('ส่งฟอร์ม'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

// ==================== Setup Main ====================

/// วิธีการใช้แบบนี้:
/// 1. Wrap ด้วย ProviderScope (สำหรับ Riverpod)
/// 2. Wrap ด้วย MultiProvider (สำหรับ Provider)
/// 3. ใช้ Consumer เพื่อ listen ต่อ AddressFormState
///
/// ```dart
/// void main() {
///   runApp(
///     ProviderScope(
///       child: MultiProvider(
///         providers: [
///           ChangeNotifierProvider(create: (_) => AddressFormState()),
///         ],
///         child: const MyApp(),
///       ),
///     ),
///   );
/// }
/// ```
*/
