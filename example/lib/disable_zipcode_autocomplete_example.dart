import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// Example: Disable Zip Code Autocomplete
///
/// This example demonstrates how to disable zip code autocomplete feature.
/// Useful when you want a simple text field for zip code input without
/// the autocomplete suggestions dropdown.
void main() {
  runApp(const MaterialApp(home: DisableZipCodeAutocompleteExample(), debugShowCheckedModeBanner: false));
}

class DisableZipCodeAutocompleteExample extends StatefulWidget {
  const DisableZipCodeAutocompleteExample({super.key});

  @override
  State<DisableZipCodeAutocompleteExample> createState() => _DisableZipCodeAutocompleteExampleState();
}

class _DisableZipCodeAutocompleteExampleState extends State<DisableZipCodeAutocompleteExample> {
  final _repository = ThaiAddressRepository();
  late ThaiAddressController _controller;
  ThaiAddress? _selectedAddress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = ThaiAddressController(repository: _repository);
    _init();
  }

  Future<void> _init() async {
    await _repository.initialize();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('ปิด Zip Code Autocomplete'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ปิด Zip Code Autocomplete'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'ตัวอย่างการปิด Autocomplete',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ใช้ showZipCodeAutocomplete: false\n'
                      'เพื่อแสดง TextField ธรรมดาแทน Autocomplete\n'
                      'เหมาะสำหรับกรณีที่ไม่ต้องการ suggestions',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form with disabled autocomplete
            const Text('ฟอร์มที่อยู่ (ไม่มี Autocomplete)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            ThaiAddressForm(
              controller: _controller,
              // ปิด Zip Code Autocomplete
              showZipCodeAutocomplete: false,
              onChanged: (address) {
                setState(() {
                  _selectedAddress = address;
                });
              },
            ),

            const SizedBox(height: 24),

            // Display selected address
            if (_selectedAddress != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text('ที่อยู่ที่เลือก:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildAddressCard(_selectedAddress!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(ThaiAddress address) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (address.provinceTh != null) _buildInfoRow('จังหวัด', address.provinceTh!),
            if (address.districtTh != null) _buildInfoRow('อำเภอ/เขต', address.districtTh!),
            if (address.subDistrictTh != null) _buildInfoRow('ตำบล/แขวง', address.subDistrictTh!),
            if (address.zipCode != null) _buildInfoRow('รหัสไปรษณีย์', address.zipCode!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
