import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการใช้ Village Autocomplete พร้อม Auto-Suggestion
/// สำหรับค้นหาหมู่บ้านแบบ real-time
class VillageAutocompleteExample extends ConsumerStatefulWidget {
  const VillageAutocompleteExample({super.key});

  @override
  ConsumerState<VillageAutocompleteExample> createState() =>
      _VillageAutocompleteExampleState();
}

class _VillageAutocompleteExampleState
    extends ConsumerState<VillageAutocompleteExample> {
  final _villageController = TextEditingController();
  Village? _selectedVillage;

  @override
  void dispose() {
    _villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initAsync = ref.watch(repositoryInitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Village Autocomplete Example'),
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
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'คุณสมบัติของ Village Autocomplete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('🎯 แนะนำหมู่บ้านอัตโนมัติขณะพิมพ์'),
                  _buildFeatureItem('🔍 Substring Matching (ค้นหาแบบยืดหยุ่น)'),
                  _buildFeatureItem(
                    '📍 แสดงลำดับชั้น: หมู่บ้าน • หมู่ • ตำบล → อำเภอ → จังหวัด',
                  ),
                  _buildFeatureItem('🏘️ แสดงหมายเลขหมู่ (หมู่ที่)'),
                  _buildFeatureItem(
                    '✨ Auto-fill ข้อมูลที่อยู่ทั้งหมดเมื่อเลือก',
                  ),
                  _buildFeatureItem('🚀 ประสิทธิภาพสูง O(k) with early exit'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Village Autocomplete Widget
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ค้นหาหมู่บ้าน',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  VillageAutocomplete(
                    controller: _villageController,
                    decoration: InputDecoration(
                      labelText: 'หมู่บ้าน',
                      hintText: 'ลองพิมพ์ "บ้าน" หรือ "ชุมชน"',
                      helperText: 'พิมพ์ชื่อเพื่อดู auto-suggestions',
                      helperMaxLines: 2,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.home),
                      suffixIcon: _villageController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _villageController.clear();
                                setState(() {
                                  _selectedVillage = null;
                                });
                                ref
                                    .read(thaiAddressNotifierProvider.notifier)
                                    .reset();
                              },
                            )
                          : null,
                    ),
                    onVillageSelected: (Village village) {
                      setState(() {
                        _selectedVillage = village;
                      });
                      if (_selectedVillage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'เลือกหมู่บ้าน: ${_selectedVillage!.nameTh} หมู่ ${_selectedVillage!.mooNo}',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Results Display
          if (_selectedVillage != null) ...[_buildResultCard(state)],

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
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'ข้อมูลหมู่บ้านและที่อยู่',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildAddressField('🏘️ หมู่บ้าน', _selectedVillage?.nameTh ?? '-'),
            const SizedBox(height: 12),
            _buildAddressField(
              '📍 หมู่ที่',
              _selectedVillage != null && _selectedVillage!.mooNo > 0
                  ? '${_selectedVillage!.mooNo}'
                  : '-',
            ),
            const SizedBox(height: 12),
            _buildAddressField(
              '🏠 ตำบล/แขวง',
              state.selectedSubDistrict?.nameTh ?? '-',
            ),
            const SizedBox(height: 12),
            _buildAddressField(
              '🏙️ อำเภอ/เขต',
              state.selectedDistrict?.nameTh ?? '-',
            ),
            const SizedBox(height: 12),
            _buildAddressField(
              '🗺️ จังหวัด',
              state.selectedProvince?.nameTh ?? '-',
            ),
            const SizedBox(height: 12),
            _buildAddressField('📮 รหัสไปรษณีย์', state.zipCode ?? '-'),
            if (_selectedVillage?.lat != null) ...[
              const Divider(height: 24),
              _buildAddressField(
                '🌐 พิกัด',
                '${_selectedVillage!.lat}, ${_selectedVillage!.long}',
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

  Widget _buildExampleCases() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ตัวอย่างการค้นหา',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '💡 ลองค้นหาคำเหล่านี้:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildExampleCase(
              'คำค้น: "บ้าน"',
              'ค้นหาหมู่บ้านทั้งหมดที่มี "บ้าน" ในชื่อ',
              Colors.blue,
            ),
            const Divider(height: 20),
            _buildExampleCase(
              'คำค้น: "ชุมชน"',
              'ค้นหาชุมชนต่างๆ',
              Colors.green,
            ),
            const Divider(height: 20),
            _buildExampleCase(
              'คำค้น: "หมู่"',
              'ค้นหาหมู่บ้านที่มี "หมู่" ในชื่อ',
              Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              '✨ ระบบจะแสดง suggestions ทันทีที่คุณเริ่มพิมพ์!',
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
