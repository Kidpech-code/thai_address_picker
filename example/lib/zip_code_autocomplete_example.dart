import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการใช้งาน ZipCodeAutocomplete widget
/// Example: ZipCode Autocomplete widget usage
class ZipCodeAutocompleteExample extends StatefulWidget {
  const ZipCodeAutocompleteExample({super.key});

  @override
  State<ZipCodeAutocompleteExample> createState() => _ZipCodeAutocompleteExampleState();
}

class _ZipCodeAutocompleteExampleState extends State<ZipCodeAutocompleteExample> {
  final _repository = ThaiAddressRepository();
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  ZipCodeSuggestion? _selectedSuggestion;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _repository.initialize();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zip Code Autocomplete')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zip Code Autocomplete')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Zip Code Autocomplete')),
      body: SingleChildScrollView(
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
                        Text('วิธีใช้งาน', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. พิมพ์รหัสไปรษณีย์ (เช่น 10110)\n'
                      '2. ระบบจะแนะนำรหัสไปรษณีย์ที่ตรงกัน\n'
                      '3. เลือกรหัสเพื่อดูข้อมูลพื้นที่',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Zip Code Autocomplete Widget
            ZipCodeAutocomplete(
              repository: _repository,
              onSuggestionSelected: (suggestion) {
                setState(() {
                  _selectedSuggestion = suggestion;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'เลือก: ${suggestion.zipCode} - '
                      '${suggestion.subDistrict.nameTh}, '
                      '${suggestion.district?.nameTh ?? ''}, '
                      '${suggestion.province?.nameTh ?? ''}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Result Display
            if (_selectedSuggestion != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final suggestion = _selectedSuggestion!;
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
                  'ผลลัพธ์ที่เลือก',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade700),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('📮 รหัสไปรษณีย์', suggestion.zipCode),
            const SizedBox(height: 8),
            _buildInfoRow('🏠 ตำบล/แขวง', suggestion.subDistrict.nameTh),
            const SizedBox(height: 8),
            _buildInfoRow('🏘️ อำเภอ/เขต', suggestion.district?.nameTh ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow('📍 จังหวัด', suggestion.province?.nameTh ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
