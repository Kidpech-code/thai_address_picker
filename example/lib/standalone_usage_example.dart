import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการใช้งานแบบ Standalone
/// Pure Dart/Flutter - ไม่พึ่งพา Riverpod, Provider หรือ state management ใดๆ
///
/// Example: Standalone Usage without any State Management
/// Pure Repository + Algorithm - Maximum Performance

class StandaloneUsageExample extends StatefulWidget {
  const StandaloneUsageExample({super.key});

  @override
  State<StandaloneUsageExample> createState() => _StandaloneUsageExampleState();
}

class _StandaloneUsageExampleState extends State<StandaloneUsageExample> {
  // Repository instance (Singleton - ไม่ต้อง state management)
  late ThaiAddressRepository _repository;

  bool _isLoading = true;
  String? _error;

  // State for selections
  Province? _selectedProvince;
  District? _selectedDistrict;
  SubDistrict? _selectedSubDistrict;
  String? _selectedZipCode;
  Village? _selectedVillage;

  // Autocomplete results
  List<ZipCodeSuggestion> _zipSuggestions = [];
  List<VillageSuggestion> _villageSuggestions = [];

  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = ThaiAddressRepository();
    _initRepository();
  }

  Future<void> _initRepository() async {
    try {
      await _repository.initialize();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _zipController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Standalone Usage')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Standalone Usage')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Standalone Usage Example'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildCascadingDropdowns(),
          const SizedBox(height: 24),
          _buildZipCodeAutocomplete(),
          const SizedBox(height: 24),
          _buildVillageAutocomplete(),
          const SizedBox(height: 24),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🚀 Pure Standalone - No State Management',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'ใช้ Repository โดยตรง - ไม่พึ่งพา Riverpod/Provider/GetX/BLoC',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚡ Maximum Performance:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildPoint('O(1) HashMap lookup'),
                _buildPoint('Isolate-based JSON parsing'),
                _buildPoint('Early-exit search algorithm'),
                _buildPoint('In-memory caching'),
                _buildPoint('Singleton pattern'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Text('✓ ', style: TextStyle(color: Colors.green)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // ==================== Cascading Dropdowns ====================

  Widget _buildCascadingDropdowns() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1️⃣ Cascading Selection',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Province
            _buildProvinceDropdown(),
            const SizedBox(height: 12),
            // District
            if (_selectedProvince != null) _buildDistrictDropdown(),
            const SizedBox(height: 12),
            // Sub-district
            if (_selectedDistrict != null) _buildSubDistrictDropdown(),
            const SizedBox(height: 12),
            // Zip Code (auto-filled)
            if (_selectedSubDistrict != null) _buildZipCodeDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    // ใช้ repository โดยตรง - O(1) access
    final provinces = _repository.provinces;

    return DropdownButtonFormField<Province>(
      value: _selectedProvince,
      decoration: const InputDecoration(
        labelText: 'จังหวัด',
        border: OutlineInputBorder(),
      ),
      items: provinces.map((p) {
        return DropdownMenuItem(value: p, child: Text(p.nameTh));
      }).toList(),
      onChanged: (province) {
        setState(() {
          _selectedProvince = province;
          _selectedDistrict = null;
          _selectedSubDistrict = null;
          _selectedZipCode = null;
        });
      },
    );
  }

  Widget _buildDistrictDropdown() {
    // O(1) lookup + filtering
    final districts = _repository.getDistrictsByProvince(_selectedProvince!.id);

    return DropdownButtonFormField<District>(
      value: _selectedDistrict,
      decoration: const InputDecoration(
        labelText: 'อำเภอ/เขต',
        border: OutlineInputBorder(),
      ),
      items: districts.map((d) {
        return DropdownMenuItem(value: d, child: Text(d.nameTh));
      }).toList(),
      onChanged: (district) {
        setState(() {
          _selectedDistrict = district;
          _selectedSubDistrict = null;
          _selectedZipCode = null;
        });
      },
    );
  }

  Widget _buildSubDistrictDropdown() {
    // O(1) lookup + filtering
    final subDistricts = _repository.getSubDistrictsByDistrict(
      _selectedDistrict!.id,
    );

    return DropdownButtonFormField<SubDistrict>(
      value: _selectedSubDistrict,
      decoration: const InputDecoration(
        labelText: 'ตำบล/แขวง',
        border: OutlineInputBorder(),
      ),
      items: subDistricts.map((s) {
        return DropdownMenuItem(value: s, child: Text(s.nameTh));
      }).toList(),
      onChanged: (subDistrict) {
        setState(() {
          _selectedSubDistrict = subDistrict;
          // Auto-fill zip code
          _selectedZipCode = subDistrict?.zipCode;
        });
      },
    );
  }

  Widget _buildZipCodeDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'รหัสไปรษณีย์:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _selectedZipCode ?? 'N/A',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Zip Code Autocomplete ====================

  Widget _buildZipCodeAutocomplete() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2️⃣ Zip Code Autocomplete (Reverse Lookup)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _zipController,
              decoration: const InputDecoration(
                labelText: 'รหัสไปรษณีย์',
                hintText: 'พิมพ์ เช่น 10110',
                prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 5,
              onChanged: (query) {
                // High-performance search with early exit
                if (query.isEmpty) {
                  setState(() => _zipSuggestions = []);
                  return;
                }

                final suggestions = _repository.searchZipCodes(
                  query,
                  maxResults: 10,
                );

                setState(() => _zipSuggestions = suggestions);
              },
            ),
            const SizedBox(height: 8),
            if (_zipSuggestions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _zipSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _zipSuggestions[index];
                    return ListTile(
                      title: Text(suggestion.displayText),
                      subtitle: Text(suggestion.displayTextEn),
                      onTap: () {
                        // Auto-fill all fields
                        setState(() {
                          _selectedSubDistrict = suggestion.subDistrict;
                          _selectedDistrict = suggestion.district;
                          _selectedProvince = suggestion.province;
                          _selectedZipCode = suggestion.zipCode;
                          _zipController.text = suggestion.zipCode;
                          _zipSuggestions = [];
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== Village Autocomplete ====================

  Widget _buildVillageAutocomplete() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3️⃣ Village Autocomplete (~70,000 villages)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _villageController,
              decoration: const InputDecoration(
                labelText: 'หมู่บ้าน',
                hintText: 'พิมพ์ชื่อหมู่บ้าน',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                // Substring matching - O(k) where k is result size
                if (query.isEmpty) {
                  setState(() => _villageSuggestions = []);
                  return;
                }

                final suggestions = _repository.searchVillages(
                  query,
                  maxResults: 15,
                );

                setState(() => _villageSuggestions = suggestions);
              },
            ),
            const SizedBox(height: 8),
            if (_villageSuggestions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _villageSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _villageSuggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: Text(suggestion.village.nameTh),
                      subtitle: Text(
                        '${suggestion.displayMoo} • ${suggestion.subDistrict?.nameTh ?? ""}',
                      ),
                      trailing: Text(
                        suggestion.district?.nameTh ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        // Auto-fill all fields
                        setState(() {
                          _selectedVillage = suggestion.village;
                          _selectedSubDistrict = suggestion.subDistrict;
                          _selectedDistrict = suggestion.district;
                          _selectedProvince = suggestion.province;
                          _selectedZipCode = _selectedSubDistrict?.zipCode;
                          _villageController.text = suggestion.village.nameTh;
                          _villageSuggestions = [];
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== Summary ====================

  Widget _buildSummary() {
    if (_selectedProvince == null) return const SizedBox.shrink();

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 สรุปข้อมูลที่เลือก',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('จังหวัด', _selectedProvince?.nameTh),
            _buildSummaryRow('Province', _selectedProvince?.nameEn),
            const SizedBox(height: 8),
            _buildSummaryRow('อำเภอ/เขต', _selectedDistrict?.nameTh),
            _buildSummaryRow('District', _selectedDistrict?.nameEn),
            const SizedBox(height: 8),
            _buildSummaryRow('ตำบล/แขวง', _selectedSubDistrict?.nameTh),
            _buildSummaryRow('Sub-district', _selectedSubDistrict?.nameEn),
            const SizedBox(height: 8),
            if (_selectedVillage != null) ...[
              _buildSummaryRow('หมู่บ้าน', _selectedVillage?.nameTh),
              _buildSummaryRow('หมู่ที่', _selectedVillage?.mooNo.toString()),
              const SizedBox(height: 8),
            ],
            _buildSummaryRow('รหัสไปรษณีย์', _selectedZipCode),
            const SizedBox(height: 16),
            // Performance info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Performance Stats:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Total Provinces: ${_repository.provinces.length}'),
                  Text('Total Villages: ${_repository.villages.length}'),
                  Text('Lookup Time: O(1)'),
                  Text('Search Time: O(k) where k = results'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
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
