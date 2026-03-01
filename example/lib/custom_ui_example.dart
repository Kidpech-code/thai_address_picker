import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการใช้งานโดยไม่ใช้ UI Widgets
/// Example: Using data only without built-in widgets
class CustomAddressFormExample extends StatefulWidget {
  const CustomAddressFormExample({super.key});

  @override
  State<CustomAddressFormExample> createState() => _CustomAddressFormExampleState();
}

class _CustomAddressFormExampleState extends State<CustomAddressFormExample> {
  final _repository = ThaiAddressRepository();
  late ThaiAddressController _controller;
  late TextEditingController _zipCodeController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _zipCodeController = TextEditingController();
    _controller = ThaiAddressController(repository: _repository);
    _init();
  }

  Future<void> _init() async {
    await _repository.initialize();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _zipCodeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Custom UI Example')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Custom UI Example')),
      body: _buildCustomForm(),
    );
  }

  Widget _buildCustomForm() {
    return ValueListenableBuilder<ThaiAddressSelection>(
      valueListenable: _controller,
      builder: (context, state, _) {
        // Sync zip code from state to controller if changed externally
        if (_zipCodeController.text != (state.zipCode ?? '')) {
          _zipCodeController.text = state.zipCode ?? '';
        }

        // Get data from repository
        final provinces = _repository.provinces;
        final districts = state.province != null ? _repository.getDistrictsByProvince(state.province!.id) : <District>[];
        final subDistricts = state.district != null ? _repository.getSubDistrictsByDistrict(state.district!.id) : <SubDistrict>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom Province Dropdown
              _buildCustomDropdown<Province>(
                label: 'จังหวัด',
                value: state.province,
                items: provinces,
                itemBuilder: (province) => Text(province.nameTh),
                onChanged: (province) => _controller.selectProvince(province),
              ),
              const SizedBox(height: 16),

              // Custom District Dropdown
              _buildCustomDropdown<District>(
                label: 'อำเภอ/เขต',
                value: state.district,
                items: districts,
                itemBuilder: (district) => Text(district.nameTh),
                onChanged: state.province != null ? (district) => _controller.selectDistrict(district) : null,
              ),
              const SizedBox(height: 16),

              // Custom SubDistrict Dropdown
              _buildCustomDropdown<SubDistrict>(
                label: 'ตำบล/แขวง',
                value: state.subDistrict,
                items: subDistricts,
                itemBuilder: (subDistrict) => Text(subDistrict.nameTh),
                onChanged: state.district != null ? (subDistrict) => _controller.selectSubDistrict(subDistrict) : null,
              ),
              const SizedBox(height: 16),

              // Custom Zip Code Field
              TextField(
                decoration: const InputDecoration(labelText: 'รหัสไปรษณีย์', border: OutlineInputBorder(), prefixIcon: Icon(Icons.local_post_office)),
                controller: _zipCodeController,
                keyboardType: TextInputType.number,
                maxLength: 5,
                onChanged: (value) => _controller.setZipCode(value),
              ),

              // Display selected address
              if (state.province != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ที่อยู่ที่เลือก:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        _buildInfoRow('จังหวัด', state.province?.nameTh ?? '-'),
                        _buildInfoRow('อำเภอ', state.district?.nameTh ?? '-'),
                        _buildInfoRow('ตำบล', state.subDistrict?.nameTh ?? '-'),
                        _buildInfoRow('รหัสไปรษณีย์', state.zipCode ?? '-'),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required void Function(T?)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(label),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(value: item, child: itemBuilder(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:')),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
