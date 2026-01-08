// ตัวอย่างการใช้งาน thai_address_picker กับ GetX
// Example: Integration with GetX state management
//
// หมายเหตุ: ต้องเพิ่ม 'get' package ใน pubspec.yaml ก่อน
// Note: Add 'get: ^4.6.5' to your pubspec.yaml dependencies to use this example
//
// This file is commented out because GetX is an optional dependency.
// Uncomment and add GetX to your project to use this integration.

/*
import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';
import 'package:get/get.dart';

// ==================== GetX Controllers ====================

/// GetX Controller สำหรับจัดการ state ของฟอร์มที่อยู่
///
/// ใช้แบบนี้:
/// ```dart
/// final controller = Get.put(AddressFormGetXController());
/// controller.selectAddress(address);
/// Get.snackbar('Success', 'Address saved!');
/// ```
class AddressFormGetXController extends GetxController {
  // Observable variables
  final Rx<ThaiAddress?> selectedAddress = Rx<ThaiAddress?>(null);
  final RxBool isSubmitting = RxBool(false);
  final RxString errorMessage = RxString('');

  /// อัปเดตที่อยู่ที่เลือก
  void selectAddress(ThaiAddress address) {
    selectedAddress.value = address;
    errorMessage.value = '';
  }

  /// ส่งฟอร์ม
  Future<void> submitForm() async {
    if (selectedAddress.value == null) {
      errorMessage.value = 'กรุณาเลือกที่อยู่ก่อน';
      return;
    }

    isSubmitting.value = true;

    try {
      // จำลองการส่งไป server
      await Future.delayed(const Duration(seconds: 2));

      final address = selectedAddress.value!;
      print('✅ ส่งที่อยู่สำเร็จ:');
      print('   จังหวัด: ${address.provinceTh}');
      print('   อำเภอ: ${address.districtTh}');
      print('   ตำบล: ${address.subDistrictTh}');

      selectedAddress.value = null;
      Get.snackbar(
        'Success',
        'Address saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to save address: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearAddress() {
    selectedAddress.value = null;
    errorMessage.value = '';
  }
}

// ==================== GetX Integration Example ====================

/// ตัวอย่างหน้าแรก สำหรับการ integrate GetX
/// 
/// วิธีการใช้:
/// ```dart
/// void main() {
///   runApp(
///     ProviderScope(
///       child: GetMaterialApp(
///         home: const GetXIntegrationExample(),
///       ),
///     ),
///   );
/// }
/// ```
class GetXIntegrationExample extends StatelessWidget {
  const GetXIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    // สร้าง controller (หรือใช้ Get.find ถ้าสร้างที่อื่น)
    final controller = Get.put(AddressFormGetXController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Integration Example'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ส่วน 1: คำอธิบาย
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Scenario 3: ใช้ร่วมกับ GetX',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ตัวอย่างนี้แสดงวิธีการใช้ thai_address_picker กับ GetX state management',
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
                      _buildPoint('ProviderScope wrap ด้านนอก'),
                      _buildPoint('GetMaterialApp wrap ด้านใน'),
                      _buildPoint('Get.put() สร้าง controller'),
                      _buildPoint('Obx() listen observable changes'),
                      _buildPoint('ไม่มี conflict ระหว่าง Riverpod กับ GetX'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ส่วน 2: ฟอร์ม
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📝 Form',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ThaiAddressForm(
                    onChanged: (address) {
                      // ส่งข้อมูลไป GetX controller
                      controller.selectAddress(address);
                    },
                    useThai: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ส่วน 3: ข้อมูลที่เลือก + Action buttons
          Obx(
            () {
              if (controller.selectedAddress.value == null) {
                return const SizedBox.shrink();
              }

              final address = controller.selectedAddress.value!;

              return Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ ที่อยู่ที่เลือก',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isSubmitting.value
                                    ? null
                                    : () => controller.submitForm(),
                                child: controller.isSubmitting.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('ส่งฟอร์ม'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => controller.clearAddress(),
                              child: const Text('ยกเลิก'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ส่วน 4: Error message
          Obx(
            () {
              if (controller.errorMessage.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Main Setup ====================

/// วิธีการใช้แบบนี้ในไฟล์ main.dart:
///
/// ```dart
/// import 'package:get/get.dart';
/// import 'package:thai_address_picker/thai_address_picker.dart';
///
/// void main() {
///   runApp(
///     ProviderScope(  // Riverpod (thai_address_picker)
///       child: GetMaterialApp(  // GetX
///         home: const GetXIntegrationExample(),
///       ),
///     ),
///   );
/// }
/// ```
///
/// ด้วยวิธีนี้:
/// - Riverpod ทำงานสำหรับ thai_address_picker
/// - GetX ทำงานสำหรับ state management ของ app
/// - ไม่มี conflict ระหว่างกัน
/// - สามารถใช้ทั้งสองแบบได้พร้อมกัน

// Dummy GetX extension
extension DummyGetX on Object {
  T put<T>(T value) => value;
  T find<T>() => throw UnimplementedError();
  void snackbar(String title, String message,
      {int snackPosition = 0,
      Color? backgroundColor,
      Color? colorText}) {}
}

class SnackPosition {
  static const int BOTTOM = 0;
  static const int TOP = 1;
}

class GetMaterialApp extends MaterialApp {
  const GetMaterialApp({
    required Widget home,
    String? title,
    ThemeData? theme,
  }) : super(
    title: title ?? '',
    home: home,
    theme: theme,
  );
}

class Obx extends StatelessWidget {
  final Widget Function() builder;

  const Obx(this.builder, {super.key});

  @override
  Widget build(BuildContext context) => builder();
}

class RxBool {
  bool value = false;
}

class RxString {
  String value = '';

  bool get isEmpty => value.isEmpty;
}

class Rx<T> {
  T? value;

  Rx(this.value);
}
*/
