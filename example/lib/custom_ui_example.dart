import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการใช้งานโดยไม่ใช้ UI Widgets
/// Example: Using data only without built-in widgets
class CustomAddressFormExample extends ConsumerStatefulWidget {
  const CustomAddressFormExample({super.key});

  @override
  ConsumerState<CustomAddressFormExample> createState() =>
      _CustomAddressFormExampleState();
}

class _CustomAddressFormExampleState
    extends ConsumerState<CustomAddressFormExample> {
  late TextEditingController _zipCodeController;

  @override
  void initState() {
    super.initState();
    _zipCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initAsync = ref.watch(repositoryInitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Custom UI Example')),
      body: initAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (_) => _buildCustomForm(),
      ),
    );
  }

  Widget _buildCustomForm() {
    final repository = ref.watch(thaiAddressRepositoryProvider);
    final state = ref.watch(thaiAddressNotifierProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    // Sync zip code from state to controller if changed externally
    if (_zipCodeController.text != (state.zipCode ?? '')) {
      _zipCodeController.text = state.zipCode ?? '';
    }

    // Get data from repository
    final provinces = repository.provinces;
    final districts = state.selectedProvince != null
        ? repository.getDistrictsByProvince(state.selectedProvince!.id)
        : <District>[];
    final subDistricts = state.selectedDistrict != null
        ? repository.getSubDistrictsByDistrict(state.selectedDistrict!.id)
        : <SubDistrict>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Custom Province Dropdown
          _buildCustomDropdown<Province>(
            label: 'จังหวัด',
            value: state.selectedProvince,
            items: provinces,
            itemBuilder: (province) => Text(province.nameTh),
            onChanged: (province) => notifier.selectProvince(province),
          ),
          const SizedBox(height: 16),

          // Custom District Dropdown
          _buildCustomDropdown<District>(
            label: 'อำเภอ/เขต',
            value: state.selectedDistrict,
            items: districts,
            itemBuilder: (district) => Text(district.nameTh),
            onChanged: state.selectedProvince != null
                ? (district) => notifier.selectDistrict(district)
                : null,
          ),
          const SizedBox(height: 16),

          // Custom SubDistrict Dropdown
          _buildCustomDropdown<SubDistrict>(
            label: 'ตำบล/แขวง',
            value: state.selectedSubDistrict,
            items: subDistricts,
            itemBuilder: (subDistrict) => Text(subDistrict.nameTh),
            onChanged: state.selectedDistrict != null
                ? (subDistrict) => notifier.selectSubDistrict(subDistrict)
                : null,
          ),
          const SizedBox(height: 16),

          // Custom Zip Code Field
          TextField(
            decoration: const InputDecoration(
              labelText: 'รหัสไปรษณีย์',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_post_office),
            ),
            controller: _zipCodeController,
            keyboardType: TextInputType.number,
            maxLength: 5,
            onChanged: (value) => notifier.setZipCode(value),
          ),

          // Display selected address
          if (state.selectedProvince != null) ...[
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ที่อยู่ที่เลือก:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'จังหวัด',
                      state.selectedProvince?.nameTh ?? '-',
                    ),
                    _buildInfoRow(
                      'อำเภอ',
                      state.selectedDistrict?.nameTh ?? '-',
                    ),
                    _buildInfoRow(
                      'ตำบล',
                      state.selectedSubDistrict?.nameTh ?? '-',
                    ),
                    _buildInfoRow('รหัสไปรษณีย์', state.zipCode ?? '-'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
