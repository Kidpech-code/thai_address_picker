import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการใช้ Zip Code Autocomplete พร้อม Auto-Suggestion
/// สำหรับแก้ปัญหารหัสไปรษณีย์ที่มีหลายพื้นที่
class ZipCodeAutocompleteExample extends ConsumerStatefulWidget {
  const ZipCodeAutocompleteExample({super.key});

  @override
  ConsumerState<ZipCodeAutocompleteExample> createState() =>
      _ZipCodeAutocompleteExampleState();
}

class _ZipCodeAutocompleteExampleState
    extends ConsumerState<ZipCodeAutocompleteExample> {
  final _zipCodeController = TextEditingController();

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initAsync = ref.watch(repositoryInitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zip Code Autocomplete Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: initAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (_) => _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final state = ref.watch(thaiAddressNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'คุณสมบัติของ Zip Code Autocomplete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('🎯 แนะนำที่อยู่อัตโนมัติขณะพิมพ์'),
                  _buildFeatureItem(
                    '⚡️ ค้นหาแบบ Prefix Matching (เริ่มต้นด้วย...)',
                  ),
                  _buildFeatureItem(
                    '📍 แสดงลำดับชั้น: รหัส → ตำบล → อำเภอ → จังหวัด',
                  ),
                  _buildFeatureItem(
                    '🔄 รองรับหลายพื้นที่ในรหัสเดียวกัน (เช่น 10200)',
                  ),
                  _buildFeatureItem('✨ Auto-fill ข้อมูลทั้งหมดเมื่อเลือก'),
                  _buildFeatureItem('🚀 ประสิทธิภาพสูง O(n) with early exit'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Zip Code Autocomplete Widget
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ค้นหารหัสไปรษณีย์',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ZipCodeAutocomplete(
                    controller: _zipCodeController,
                    decoration: InputDecoration(
                      labelText: 'รหัสไปรษณีย์',
                      hintText: 'ลองพิมพ์ 102 หรือ 500',
                      helperText: 'พิมพ์ตัวเลขเพื่อดู auto-suggestions',
                      helperMaxLines: 2,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.local_post_office),
                      suffixIcon: _zipCodeController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _zipCodeController.clear();
                                ref
                                    .read(thaiAddressNotifierProvider.notifier)
                                    .reset();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onZipCodeSelected: (zipCode) {
                      setState(() {}); // Refresh UI
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('เลือกรหัสไปรษณีย์: $zipCode'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Results Display
          if (state.selectedProvince != null) ...[
            _buildResultCard(state),
          ] else if (state.error != null) ...[
            _buildErrorCard(state.error!),
          ],

          const SizedBox(height: 24),

          // Example Cases
          _buildExampleCases(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
    );
  }

  Widget _buildResultCard(ThaiAddressState state) {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'ข้อมูลที่อยู่สำเร็จ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildAddressField('📮 รหัสไปรษณีย์', state.zipCode ?? '-'),
            const SizedBox(height: 12),
            _buildAddressField(
              '🏠 ตำบล/แขวง',
              '${state.selectedSubDistrict?.nameTh ?? '-'} (${state.selectedSubDistrict?.nameEn ?? '-'})',
            ),
            const SizedBox(height: 12),
            _buildAddressField(
              '🏘️ อำเภอ/เขต',
              '${state.selectedDistrict?.nameTh ?? '-'} (${state.selectedDistrict?.nameEn ?? '-'})',
            ),
            const SizedBox(height: 12),
            _buildAddressField(
              '📍 จังหวัด',
              '${state.selectedProvince?.nameTh ?? '-'} (${state.selectedProvince?.nameEn ?? '-'})',
            ),
            if (state.selectedSubDistrict?.lat != null) ...[
              const Divider(height: 24),
              _buildAddressField(
                '🌐 พิกัด',
                '${state.selectedSubDistrict!.lat}, ${state.selectedSubDistrict!.long}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCases() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ตัวอย่างการใช้งาน',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '💡 กรณีทดสอบที่แนะนำ:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildExampleCase(
              'รหัส: 10200',
              'มีหลายพื้นที่: เขตพระนคร, เขตป้อมปราบฯ, เขตสัมพันธวงศ์',
              Colors.orange,
            ),
            const Divider(height: 20),
            _buildExampleCase(
              'รหัส: 10110',
              'เขตบางกอกใหญ่, กรุงเทพมหานคร (พื้นที่เดียว)',
              Colors.green,
            ),
            const Divider(height: 20),
            _buildExampleCase(
              'รหัส: 50000',
              'เชียงใหม่ จังหวัดเชียงใหม่',
              Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              '✨ ลองพิมพ์เพียงบางตัวเลข (เช่น "102" หรือ "500") เพื่อดู auto-suggestions ทำงาน!',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCase(String title, String description, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}
