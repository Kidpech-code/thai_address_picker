import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// Example: Compare Zip Code Autocomplete vs Simple TextField
///
/// This example demonstrates the difference between:
/// 1. Form with autocomplete enabled (default)
/// 2. Form with autocomplete disabled (simple text field)
void main() {
  runApp(
    const MaterialApp(
      home: CompareZipCodeModesExample(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class CompareZipCodeModesExample extends StatefulWidget {
  const CompareZipCodeModesExample({super.key});

  @override
  State<CompareZipCodeModesExample> createState() =>
      _CompareZipCodeModesExampleState();
}

class _CompareZipCodeModesExampleState
    extends State<CompareZipCodeModesExample> {
  final _repository = ThaiAddressRepository();
  late ThaiAddressController _autocompleteController;
  late ThaiAddressController _simpleController;
  ThaiAddress? _autocompleteAddress;
  ThaiAddress? _simpleAddress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _autocompleteController =
        ThaiAddressController(repository: _repository);
    _simpleController = ThaiAddressController(repository: _repository);
    _init();
  }

  Future<void> _init() async {
    await _repository.initialize();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _autocompleteController.dispose();
    _simpleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('เปรียบเทียบ Autocomplete vs Simple'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('เปรียบเทียบ Autocomplete vs Simple'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 เปรียบเทียบสองแบบ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Autocomplete: แสดง suggestions ขณะพิมพ์\n'
                      '• Simple: TextField ธรรมดาสำหรับกรอกเลขไปรษณีย์',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Autocomplete Form
            _buildSectionTitle(
              '1️⃣ แบบมี Autocomplete (เริ่มต้น)',
              Colors.green,
            ),
            const SizedBox(height: 8),
            const Text(
              'พิมพ์รหัสไปรษณีย์เพื่อดู suggestions',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            ThaiAddressForm(
              controller: _autocompleteController,
              showZipCodeAutocomplete: true,
              onChanged: (address) {
                setState(() {
                  _autocompleteAddress = address;
                });
              },
            ),
            if (_autocompleteAddress != null) ...[
              const SizedBox(height: 12),
              _buildAddressSummary(_autocompleteAddress!, Colors.green),
            ],

            const SizedBox(height: 32),
            const Divider(thickness: 2),
            const SizedBox(height: 32),

            // Simple TextField Form
            _buildSectionTitle('2️⃣ แบบไม่มี Autocomplete', Colors.orange),
            const SizedBox(height: 8),
            const Text(
              'พิมพ์รหัสไปรษณีย์โดยตรง (ไม่มี suggestions)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            ThaiAddressForm(
              controller: _simpleController,
              showZipCodeAutocomplete: false,
              onChanged: (address) {
                setState(() {
                  _simpleAddress = address;
                });
              },
            ),
            if (_simpleAddress != null) ...[
              const SizedBox(height: 12),
              _buildAddressSummary(_simpleAddress!, Colors.orange),
            ],

            const SizedBox(height: 32),

            // Feature Comparison Table
            _buildComparisonTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAddressSummary(ThaiAddress address, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${address.provinceTh ?? "-"} › '
              '${address.districtTh ?? "-"} › '
              '${address.subDistrictTh ?? "-"} › '
              '${address.zipCode ?? "-"}',
              style: TextStyle(fontSize: 13, color: color.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 เปรียบเทียบฟีเจอร์',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
              },
              children: [
                _buildTableRow(
                  'คุณสมบัติ',
                  'Autocomplete',
                  'Simple',
                  isHeader: true,
                ),
                _buildTableRow('Suggestions ขณะพิมพ์', '✅', '❌'),
                _buildTableRow('Auto-fill ที่อยู่', '✅', '❌'),
                _buildTableRow('แสดงหลายพื้นที่', '✅', '❌'),
                _buildTableRow('ความเร็ว', 'ปกติ', 'เร็วกว่า'),
                _buildTableRow('เหมาะสำหรับ', 'UX ที่ดี', 'ความเรียบง่าย'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    String feature,
    String autocomplete,
    String simple, {
    bool isHeader = false,
  }) {
    final textStyle = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: isHeader ? 14 : 13,
    );

    final cellColor = isHeader ? Colors.grey.shade100 : Colors.white;

    return TableRow(
      decoration: BoxDecoration(color: cellColor),
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(feature, style: textStyle),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            autocomplete,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(simple, style: textStyle, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
