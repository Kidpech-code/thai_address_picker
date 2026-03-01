import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการใช้งานแบบครบถ้วน
/// Example: Complete integration with all widgets
class CompleteIntegrationExample extends StatefulWidget {
  const CompleteIntegrationExample({super.key});

  @override
  State<CompleteIntegrationExample> createState() => _CompleteIntegrationExampleState();
}

class _CompleteIntegrationExampleState extends State<CompleteIntegrationExample> {
  final _repository = ThaiAddressRepository();
  late ThaiAddressController _controller;
  final _pageController = PageController();
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = ThaiAddressController(repository: _repository);
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
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complete Integration')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complete Integration')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Integration'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [_buildTabButton('Form', 0), _buildTabButton('Zip Code', 1), _buildTabButton('Village', 2), _buildTabButton('Summary', 3)],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [_buildFormPage(), _buildZipCodePage(), _buildVillagePage(), _buildSummaryPage()],
      ),
    );
  }

  Widget _buildTabButton(String label, int page) {
    final isActive = _currentPage == page;
    return Expanded(
      child: InkWell(
        onTap: () => _goToPage(page),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isActive ? Colors.white : Colors.transparent, width: 3)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: isActive ? Colors.white : Colors.white60, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Widget _buildFormPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Thai Address Form', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('เลือกที่อยู่จากดรอปดาวน์'),
          const SizedBox(height: 16),
          ThaiAddressForm(
            controller: _controller,
            useThai: true,
            onChanged: (address) {
              debugPrint('Address changed: ${address.toString()}');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildZipCodePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Zip Code Autocomplete', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('พิมพ์รหัสไปรษณีย์เพื่อค้นหา'),
          const SizedBox(height: 16),
          ZipCodeAutocomplete(
            repository: _repository,
            onSuggestionSelected: (suggestion) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'เลือก: ${suggestion.zipCode} - '
                    '${suggestion.subDistrict.nameTh}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVillagePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Village Autocomplete', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('พิมพ์ชื่อหมู่บ้านเพื่อค้นหา'),
          const SizedBox(height: 16),
          VillageAutocomplete(
            repository: _repository,
            onSuggestionSelected: (suggestion) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'เลือก: ${suggestion.village.nameTh} - '
                    '${suggestion.subDistrict?.nameTh ?? ''}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPage() {
    return ValueListenableBuilder<ThaiAddressSelection>(
      valueListenable: _controller,
      builder: (context, state, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Address Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow('จังหวัด', state.province?.nameTh ?? '-'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('อำเภอ/เขต', state.district?.nameTh ?? '-'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('ตำบล/แขวง', state.subDistrict?.nameTh ?? '-'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('รหัสไปรษณีย์', state.zipCode ?? '-'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _controller.reset();
                  _goToPage(0);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('เริ่มใหม่'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
