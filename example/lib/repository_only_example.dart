import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการใช้งาน thai_address_picker กับ Repository เท่านั้น
/// โดยไม่ต้องใช้ ProviderScope (Scenario 2)
///
/// Example: Using Repository only without ProviderScope
/// Perfect for: Projects that already use other state management

class RepositoryOnlyExample extends StatefulWidget {
  const RepositoryOnlyExample({super.key});

  @override
  State<RepositoryOnlyExample> createState() => _RepositoryOnlyExampleState();
}

class _RepositoryOnlyExampleState extends State<RepositoryOnlyExample> {
  late ThaiAddressRepository _repository;
  bool _isInitialized = false;
  String? _selectedProvinceId;
  String? _selectedDistrictId;
  String? _selectedSubDistrictId;
  String? _selectedZipCode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = ThaiAddressRepository();
    _initRepository();
  }

  void _initRepository() async {
    try {
      await _repository.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Error initializing repository: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository Only Example'),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(_error!),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading data...'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ส่วน 1: คำอธิบาย
        Card(
          color: Colors.amber.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Scenario 2: Repository Only (ไม่ต้อง ProviderScope)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'สำหรับโปรเจค ที่ใช้ state management อื่นแล้ว เช่น BLoC, GetX, Redux เป็นต้น',
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
                    _buildPoint('ไม่ต้อง ProviderScope ❌'),
                    _buildPoint('สร้าง Repository เอง 👇'),
                    _buildPoint(
                      'จัดการ state ด้วย setState (หรือ state management อื่น)',
                    ),
                    _buildPoint('ควบคุมได้เต็มที่'),
                    _buildPoint('เหมาะสำหรับ custom UI'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ส่วน 2: ฟอร์ม
        _buildProvinceDropdown(),
        const SizedBox(height: 16),
        if (_selectedProvinceId != null) _buildDistrictDropdown(),
        const SizedBox(height: 16),
        if (_selectedDistrictId != null) _buildSubDistrictDropdown(),
        const SizedBox(height: 16),
        if (_selectedSubDistrictId != null) _buildZipCodeField(),
        const SizedBox(height: 24),

        // ส่วน 3: ข้อมูลสรุป
        if (_selectedProvinceId != null) _buildSummary(context),
      ],
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

  Widget _buildProvinceDropdown() {
    final provinces = _repository.provinces;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('จังหวัด', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedProvinceId,
              hint: const Text('เลือกจังหวัด'),
              items: provinces.map((p) {
                return DropdownMenuItem(
                  value: p.id.toString(),
                  child: Text(p.nameTh),
                );
              }).toList(),
              onChanged: (provinceId) {
                setState(() {
                  _selectedProvinceId = provinceId;
                  _selectedDistrictId = null;
                  _selectedSubDistrictId = null;
                  _selectedZipCode = null;
                });
              },
            ),
            if (_selectedProvinceId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildProvinceInfo(provinces),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceInfo(List<Province> provinces) {
    final selected = provinces.firstWhere(
      (p) => p.id.toString() == _selectedProvinceId,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${selected.id}'),
          Text('ชื่ออังกฤษ: ${selected.nameEn}'),
          Text(
            'ทั้งหมด ${_repository.getDistrictsByProvince(selected.id).length} อำเภอ',
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    final provinceId = int.parse(_selectedProvinceId!);
    final districts = _repository.getDistrictsByProvince(provinceId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('อำเภอ/เขต', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedDistrictId,
              hint: const Text('เลือกอำเภอ'),
              items: districts.map((d) {
                return DropdownMenuItem(
                  value: d.id.toString(),
                  child: Text(d.nameTh),
                );
              }).toList(),
              onChanged: (districtId) {
                setState(() {
                  _selectedDistrictId = districtId;
                  _selectedSubDistrictId = null;
                  _selectedZipCode = null;
                });
              },
            ),
            if (_selectedDistrictId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildDistrictInfo(districts),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictInfo(List<District> districts) {
    final selected = districts.firstWhere(
      (d) => d.id.toString() == _selectedDistrictId,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${selected.id}'),
          Text('ชื่ออังกฤษ: ${selected.nameEn}'),
          Text(
            'ทั้งหมด ${_repository.getSubDistrictsByDistrict(selected.id).length} ตำบล',
          ),
        ],
      ),
    );
  }

  Widget _buildSubDistrictDropdown() {
    final districtId = int.parse(_selectedDistrictId!);
    final subDistricts = _repository.getSubDistrictsByDistrict(districtId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ตำบล/แขวง', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedSubDistrictId,
              hint: const Text('เลือกตำบล'),
              items: subDistricts.map((s) {
                return DropdownMenuItem(
                  value: s.id.toString(),
                  child: Text(s.nameTh),
                );
              }).toList(),
              onChanged: (subDistrictId) {
                setState(() {
                  _selectedSubDistrictId = subDistrictId;
                  // Auto-fill zip code
                  final selected = subDistricts.firstWhere(
                    (s) => s.id.toString() == subDistrictId,
                  );
                  _selectedZipCode = selected.zipCode;
                });
              },
            ),
            if (_selectedSubDistrictId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildSubDistrictInfo(subDistricts),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubDistrictInfo(List<SubDistrict> subDistricts) {
    final selected = subDistricts.firstWhere(
      (s) => s.id.toString() == _selectedSubDistrictId,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${selected.id}'),
          Text('ชื่ออังกฤษ: ${selected.nameEn}'),
          Text('ละติจูด: ${selected.lat}'),
          Text('ลองจิจูด: ${selected.long}'),
        ],
      ),
    );
  }

  Widget _buildZipCodeField() {
    final subDistrictId = int.parse(_selectedSubDistrictId!);
    final subDistrict = _repository.getSubDistrictById(subDistrictId);
    final zipCode = subDistrict?.zipCode;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รหัสไปรษณีย์',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (zipCode != null)
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(zipCode),
                tileColor: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            else
              const Text('ไม่มีข้อมูลรหัสไปรษณีย์'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final provinceId = int.parse(_selectedProvinceId!);
    final provinces = _repository.provinces;
    Province? province;
    try {
      province = provinces.firstWhere((p) => p.id == provinceId);
    } catch (e) {
      province = null;
    }

    final districtId = _selectedDistrictId != null
        ? int.parse(_selectedDistrictId!)
        : null;
    District? district;
    if (districtId != null) {
      try {
        district = _repository.provinces
            .expand((p) => _repository.getDistrictsByProvince(p.id))
            .firstWhere((d) => d.id == districtId);
      } catch (e) {
        district = null;
      }
    }

    final subDistrictId = _selectedSubDistrictId != null
        ? int.parse(_selectedSubDistrictId!)
        : null;
    SubDistrict? subDistrict;
    if (subDistrictId != null) {
      try {
        subDistrict = _repository.provinces
            .expand((p) => _repository.getDistrictsByProvince(p.id))
            .expand((d) => _repository.getSubDistrictsByDistrict(d.id))
            .firstWhere((s) => s.id == subDistrictId);
      } catch (e) {
        subDistrict = null;
      }
    }

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 สรุปที่อยู่ที่เลือก',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (province != null) ...[
              _buildSummaryRow('จังหวัด', province.nameTh),
              _buildSummaryRow('Province', province.nameEn),
            ],
            if (district != null) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('อำเภอ/เขต', district.nameTh),
              _buildSummaryRow('District', district.nameEn),
            ],
            if (subDistrict != null) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('ตำบล/แขวง', subDistrict.nameTh),
              _buildSummaryRow('Sub-district', subDistrict.nameEn),
              _buildSummaryRow('ละติจูด', subDistrict.lat.toString()),
              _buildSummaryRow('ลองจิจูด', subDistrict.long.toString()),
            ],
            if (_selectedZipCode != null) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('รหัสไปรษณีย์', _selectedZipCode!),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ เลือก: ${province?.nameTh}, ${district?.nameTh}, ${subDistrict?.nameTh}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('ยืนยันที่อยู่'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
