import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการค้นหาที่อยู่จากรหัสไปรษณีย์
/// Example: Reverse lookup - Zip Code → Address
class ZipCodeLookupExample extends StatefulWidget {
  const ZipCodeLookupExample({super.key});

  @override
  State<ZipCodeLookupExample> createState() => _ZipCodeLookupExampleState();
}

class _ZipCodeLookupExampleState extends State<ZipCodeLookupExample> {
  final _repository = ThaiAddressRepository();
  late ThaiAddressController _controller;
  final _zipCodeController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = ThaiAddressController(repository: _repository);
    _init();
  }

  Future<void> _init() async {
    try {
      await _repository.initialize();
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zip Code Lookup Example')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zip Code Lookup Example')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Zip Code Lookup Example')),
      body: _buildLookupForm(),
    );
  }

  Widget _buildLookupForm() {
    return ValueListenableBuilder<ThaiAddressSelection>(
      valueListenable: _controller,
      builder: (context, state, _) {
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
                          const Text('วิธีใช้งาน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                            _controller.reset();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                maxLength: 5,
                onChanged: (zipCode) {
                  setState(() {}); // Update UI for clear button
                  _controller.setZipCode(zipCode);
                },
              ),
              const SizedBox(height: 24),

              // Results Display
              if (state.province != null) ...[
                _buildSuccessCard(state),
              ] else if (state.error != null) ...[
                _buildErrorCard(state.error!),
              ] else if (state.zipCode != null && state.zipCode!.length == 5 && state.province == null) ...[
                _buildMultipleSubDistrictsCard(state.zipCode!),
              ] else if (_zipCodeController.text.length == 5) ...[
                _buildSearchingCard(),
              ],

              // Example Zip Codes from real data
              const SizedBox(height: 32),
              const Text('รหัสไปรษณีย์ที่สามารถทดสอบ (ข้อมูลจริงจากฐานข้อมูล):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _buildRealZipCodes(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealZipCodes() {
    // Get unique zip codes from real data, take first 10
    final uniqueZips = <String>{};
    final examples = <Map<String, String>>[];

    for (var subDistrict in _repository.subDistricts) {
      if (uniqueZips.add(subDistrict.zipCode) && examples.length < 10) {
        final district = _repository.getDistrictById(subDistrict.districtId);
        final province = district != null ? _repository.getProvinceById(district.provinceId) : null;

        examples.add({'zip': subDistrict.zipCode, 'name': '${province?.nameTh ?? ''} - ${district?.nameTh ?? ''}'});
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
            _controller.setZipCode(example['zip']!);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSuccessCard(ThaiAddressSelection state) {
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade700),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildAddressRow('📍 จังหวัด', state.province!.nameTh, state.province!.nameEn),
            const SizedBox(height: 8),
            _buildAddressRow('🏘️ อำเภอ/เขต', state.district?.nameTh ?? '-', state.district?.nameEn ?? '-'),
            const SizedBox(height: 8),
            _buildAddressRow('🏠 ตำบล/แขวง', state.subDistrict?.nameTh ?? '-', state.subDistrict?.nameEn ?? '-'),
            const SizedBox(height: 8),
            _buildAddressRow('📮 รหัสไปรษณีย์', state.zipCode ?? '-', null),
            if (state.subDistrict?.lat != null) ...[
              const Divider(height: 24),
              Text('📌 พิกัด: ${state.subDistrict!.lat}, ${state.subDistrict!.long}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        const SizedBox(height: 2),
        Text(valueTh, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        if (valueEn != null) Text(valueEn, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
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
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('กำลังค้นหา...'),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleSubDistrictsCard(String zipCode) {
    final subDistricts = _repository.getSubDistrictsByZipCode(zipCode);

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
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('กรุณาเลือกพื้นที่ที่ต้องการ:', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            ...subDistricts.map((subDistrict) {
              final district = _repository.getDistrictById(subDistrict.districtId);
              final province = district != null ? _repository.getProvinceById(district.provinceId) : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on, size: 20),
                  title: Text(subDistrict.nameTh, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${district?.nameTh ?? ''} • ${province?.nameTh ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    if (province != null) {
                      _controller.selectProvince(province);
                      _controller.selectDistrict(district);
                      _controller.selectSubDistrict(subDistrict);
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
