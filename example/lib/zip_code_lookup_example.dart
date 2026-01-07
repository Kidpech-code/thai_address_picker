import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการค้นหาที่อยู่จากรหัสไปรษณีย์
/// Example: Reverse lookup - Zip Code → Address
class ZipCodeLookupExample extends ConsumerStatefulWidget {
  const ZipCodeLookupExample({super.key});

  @override
  ConsumerState<ZipCodeLookupExample> createState() =>
      _ZipCodeLookupExampleState();
}

class _ZipCodeLookupExampleState extends ConsumerState<ZipCodeLookupExample> {
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
      appBar: AppBar(title: const Text('Zip Code Lookup Example')),
      body: initAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (_) => _buildLookupForm(),
      ),
    );
  }

  Widget _buildLookupForm() {
    final state = ref.watch(thaiAddressNotifierProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'วิธีใช้งาน',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. กรอกรหัสไปรษณีย์ 5 หลัก\n'
                    '2. ระบบจะค้นหาที่อยู่โดยอัตโนมัติ\n'
                    '3. ตำบล → อำเภอ → จังหวัด จะถูกเติมโดยอัตโนมัติ',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Zip Code Input
          TextField(
            controller: _zipCodeController,
            decoration: InputDecoration(
              labelText: 'รหัสไปรษณีย์',
              hintText: 'กรอก 5 หลัก เช่น 10110',
              helperText: 'ระบบจะค้นหาที่อยู่โดยอัตโนมัติ',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.local_post_office),
              suffixIcon: _zipCodeController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _zipCodeController.clear();
                        notifier.reset();
                      },
                    )
                  : null,
            ),
            keyboardType: TextInputType.number,
            maxLength: 5,
            onChanged: (zipCode) {
              setState(() {}); // Update UI for clear button
              // Trigger reverse lookup
              notifier.setZipCode(zipCode);
            },
          ),
          const SizedBox(height: 24),

          // Results Display
          if (state.selectedProvince != null) ...[
            _buildSuccessCard(state),
          ] else if (state.error != null) ...[
            _buildErrorCard(state.error!),
          ] else if (state.zipCode != null &&
              state.zipCode!.length == 5 &&
              state.selectedProvince == null) ...[
            // Multiple subdistricts - show selection
            _buildMultipleSubDistrictsCard(state.zipCode!),
          ] else if (_zipCodeController.text.length == 5) ...[
            _buildSearchingCard(),
          ],

          // Example Zip Codes from real data
          const SizedBox(height: 32),
          const Text(
            'รหัสไปรษณีย์ที่สามารถทดสอบ (ข้อมูลจริงจากฐานข้อมูล):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildRealZipCodes(),
        ],
      ),
    );
  }

  Widget _buildRealZipCodes() {
    final repository = ref.watch(thaiAddressRepositoryProvider);

    // Get unique zip codes from real data, take first 10
    final uniqueZips = <String>{};
    final examples = <Map<String, String>>[];

    for (var subDistrict in repository.subDistricts) {
      if (uniqueZips.add(subDistrict.zipCode) && examples.length < 10) {
        final district = repository.getDistrictById(subDistrict.districtId);
        final province = district != null
            ? repository.getProvinceById(district.provinceId)
            : null;

        examples.add({
          'zip': subDistrict.zipCode,
          'name': '${province?.nameTh ?? ''} - ${district?.nameTh ?? ''}',
        });
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: examples.map((example) {
        return ActionChip(
          label: Text('${example['zip']} - ${example['name']}'),
          onPressed: () {
            _zipCodeController.text = example['zip']!;
            ref
                .read(thaiAddressNotifierProvider.notifier)
                .setZipCode(example['zip']!);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSuccessCard(ThaiAddressState state) {
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
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'พบที่อยู่',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildAddressRow(
              '📍 จังหวัด',
              state.selectedProvince!.nameTh,
              state.selectedProvince!.nameEn,
            ),
            const SizedBox(height: 8),
            _buildAddressRow(
              '🏘️ อำเภอ/เขต',
              state.selectedDistrict?.nameTh ?? '-',
              state.selectedDistrict?.nameEn ?? '-',
            ),
            const SizedBox(height: 8),
            _buildAddressRow(
              '🏠 ตำบล/แขวง',
              state.selectedSubDistrict?.nameTh ?? '-',
              state.selectedSubDistrict?.nameEn ?? '-',
            ),
            const SizedBox(height: 8),
            _buildAddressRow('📮 รหัสไปรษณีย์', state.zipCode ?? '-', null),
            if (state.selectedSubDistrict?.lat != null) ...[
              const Divider(height: 24),
              Text(
                '📌 พิกัด: ${state.selectedSubDistrict!.lat}, ${state.selectedSubDistrict!.long}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(String label, String valueTh, String? valueEn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 2),
        Text(
          valueTh,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (valueEn != null)
          Text(
            valueEn,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchingCard() {
    return Card(
      color: Colors.orange.shade50,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('กำลังค้นหา...'),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleSubDistrictsCard(String zipCode) {
    final repository = ref.watch(thaiAddressRepositoryProvider);
    final subDistricts = repository.getSubDistrictsByZipCode(zipCode);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รหัสไปรษณีย์นี้มีหลายพื้นที่ (${subDistricts.length} แห่ง)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'กรุณาเลือกพื้นที่ที่ต้องการ:',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            ...subDistricts.map((subDistrict) {
              final district = repository.getDistrictById(
                subDistrict.districtId,
              );
              final province = district != null
                  ? repository.getProvinceById(district.provinceId)
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on, size: 20),
                  title: Text(
                    subDistrict.nameTh,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${district?.nameTh ?? ''} • ${province?.nameTh ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    // Manually set all selections
                    if (province != null) {
                      notifier.selectProvince(province);
                      notifier.selectDistrict(district);
                      notifier.selectSubDistrict(subDistrict);
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
