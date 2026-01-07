import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thai Address Picker Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  ThaiAddress? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text('Thai Address Picker Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Example 1: Direct Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example 1: Direct Form', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    ThaiAddressForm(
                      onChanged: (address) {
                        setState(() {
                          _selectedAddress = address;
                        });
                      },
                      useThai: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example 2: Bottom Sheet Picker
            ElevatedButton.icon(
              onPressed: () async {
                final address = await ThaiAddressPicker.showBottomSheet(context: context, useThai: true);

                if (address != null) {
                  setState(() {
                    _selectedAddress = address;
                  });
                }
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Open Bottom Sheet Picker'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 12),

            // Example 3: Dialog Picker
            OutlinedButton.icon(
              onPressed: () async {
                final address = await ThaiAddressPicker.showDialog(context: context, useThai: true);

                if (address != null) {
                  setState(() {
                    _selectedAddress = address;
                  });
                }
              },
              icon: const Icon(Icons.map),
              label: const Text('Open Dialog Picker'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 24),

            // Display selected address
            if (_selectedAddress != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text('Selected Address:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildAddressInfo('จังหวัด (TH)', _selectedAddress!.provinceTh),
              _buildAddressInfo('Province (EN)', _selectedAddress!.provinceEn),
              _buildAddressInfo('อำเภอ (TH)', _selectedAddress!.districtTh),
              _buildAddressInfo('District (EN)', _selectedAddress!.districtEn),
              _buildAddressInfo('ตำบล (TH)', _selectedAddress!.subDistrictTh),
              _buildAddressInfo('Sub-district (EN)', _selectedAddress!.subDistrictEn),
              _buildAddressInfo('รหัสไปรษณีย์', _selectedAddress!.zipCode),
              if (_selectedAddress!.lat != null) _buildAddressInfo('Latitude', _selectedAddress!.lat.toString()),
              if (_selectedAddress!.long != null) _buildAddressInfo('Longitude', _selectedAddress!.long.toString()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInfo(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
