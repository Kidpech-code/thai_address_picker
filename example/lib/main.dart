import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';
import 'custom_ui_example.dart';
import 'zip_code_lookup_example.dart';
import 'zip_code_autocomplete_example.dart';
import 'village_autocomplete_example.dart';
// import 'provider_integration_example.dart';  // Commented out - requires provider package
import 'repository_only_example.dart';
// import 'getx_integration_example.dart';  // Commented out - requires get package
import 'complete_integration_example.dart';
import 'standalone_usage_example.dart';

void main() {
  runApp(const MyApp());
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
  final _repository = ThaiAddressRepository();
  late ThaiAddressController _controller;
  ThaiAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _controller = ThaiAddressController(repository: _repository);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text('Thai Address Picker Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navigation to examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('State Management Integration Examples', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.rocket_launch),
                      title: const Text('⭐ Standalone Usage'),
                      subtitle: const Text('Pure Repository - No State Management'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const StandaloneUsageExample()));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.auto_awesome),
                      title: const Text('Complete Integration'),
                      subtitle: const Text('All features in one example'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteIntegrationExample()));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.architecture),
                      title: const Text('Provider Integration'),
                      subtitle: const Text('Scenario 3: ใช้กับ Provider package'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Provider example is commented out - requires provider package
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Provider example requires "provider" package. '
                              'Add it to pubspec.yaml to use this example.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         const ProviderIntegrationExample(),
                        //   ),
                        // );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Repository Only'),
                      subtitle: const Text('Scenario 2: ไม่ต้อง ProviderScope'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RepositoryOnlyExample()));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.widgets),
                      title: const Text('GetX Integration'),
                      subtitle: const Text('Scenario 3: ใช้กับ GetX'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // GetX example is commented out - requires get package
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'GetX example requires "get" package. '
                              'Add it to pubspec.yaml to use this example.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         const GetXIntegrationExample(),
                        //   ),
                        // );
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('Feature Examples', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.edit_note),
                      title: const Text('Custom UI Example'),
                      subtitle: const Text('ใช้เฉพาะข้อมูล ไม่ใช้ UI Widgets'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomAddressFormExample()));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.search),
                      title: const Text('Zip Code Lookup'),
                      subtitle: const Text('ค้นหาที่อยู่จากรหัสไปรษณีย์'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ZipCodeLookupExample()));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.auto_awesome),
                      title: const Text('Zip Code Autocomplete ✨'),
                      subtitle: const Text('Auto-suggestion แก้ปัญหาหลายพื้นที่'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ZipCodeAutocompleteExample()));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.home_work),
                      title: const Text('Village Autocomplete 🏘️'),
                      subtitle: const Text('ค้นหาหมู่บ้านแบบ real-time'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const VillageAutocompleteExample()));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
                      controller: _controller,
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
