# Thai Address Picker 🇹🇭

A high-performance Flutter package for Thai address selection with Province (จังหวัด), District (อำเภอ/เขต), Sub-district (ตำบล/แขวง), and Zip Code (รหัสไปรษณีย์) support.

## Features ✨

- 🚀 **High Performance**: Uses Isolates for background JSON parsing
- 🔄 **Cascading Selection**: Province → District → Sub-district → Auto-fill Zip Code
- 🔍 **Reverse Lookup**: Enter Zip Code → Auto-fill Sub-district, District, Province
- ✨ **Zip Code Autocomplete**: Real-time suggestions with full address preview (NEW in v0.2.0)
- 🎯 **Multi-Area Support**: Handles zip codes with multiple locations (e.g., 10200)
- 🎨 **Customizable UI**: Full control over styling and decoration
- 🧩 **Flexible**: Use built-in widgets OR just data/state for your own UI
- 📦 **State Management**: Built with Riverpod for clean architecture 
- 💾 **Caching**: Data loaded once and cached in memory
- 🌐 **Bilingual**: Thai and English support

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  thai_address_picker: ^0.2.0
```

## Usage

### 1. Wrap your app with ProviderScope

```dart
import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. Use ThaiAddressForm widget

```dart
import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

class AddressFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thai Address Form')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ThaiAddressForm(
          onChanged: (ThaiAddress address) {
            print('Selected Province: ${address.provinceTh}');
            print('Selected District: ${address.districtTh}');
            print('Selected Sub-district: ${address.subDistrictTh}');
            print('Zip Code: ${address.zipCode}');
          },
          useThai: true, // Use Thai labels (default: true)
        ),
      ),
    );
  }
}
```

### 3. Use ThaiAddressPicker (Bottom Sheet)

```dart
ElevatedButton(
  onPressed: () async {
    final address = await ThaiAddressPicker.showBottomSheet(
      context: context,
      useThai: true,
    );

    if (address != null) {
      print('Selected address: ${address.provinceTh}, ${address.districtTh}');
    }
  },
  child: Text('Pick Address'),
)
```

### 4. Use ThaiAddressPicker (Dialog)

```dart
ElevatedButton(
  onPressed: () async {
    final address = await ThaiAddressPicker.showDialog(
      context: context,
      useThai: true,
    );

    if (address != null) {
      print('Selected address: ${address.provinceTh}');
    }
  },
  child: Text('Pick Address'),
)
```

### 5. Use Zip Code Autocomplete (NEW ✨)

Real-time suggestions while typing with smart multi-area support:

```dart
import 'package:thai_address_picker/thai_address_picker.dart';

class MyForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ZipCodeAutocomplete(
      decoration: InputDecoration(
        labelText: 'รหัสไปรษณีย์',
        hintText: 'พิมพ์เพื่อดู suggestions',
        helperText: 'ระบบจะแนะนำที่อยู่อัตโนมัติ',
      ),
      onZipCodeSelected: (zipCode) {
        // Auto-filled! All address fields are updated
        final state = ref.read(thaiAddressNotifierProvider);
        print('Province: ${state.selectedProvince?.nameTh}');
        print('District: ${state.selectedDistrict?.nameTh}');
        print('SubDistrict: ${state.selectedSubDistrict?.nameTh}');
      },
    );
  }
}
```

**Features:**

- 🎯 Shows suggestions as you type (prefix matching)
- 📍 Displays: ZipCode → SubDistrict → District → Province
- ⚡ High-performance search with early exit
- 🔄 Auto-fills all fields when selected
- ✨ Handles multiple areas with same zip code (e.g., 10200)

## Customization

### Custom Styling

```dart
ThaiAddressForm(
  textStyle: TextStyle(
    fontSize: 16,
    color: Colors.blue,
  ),
  provinceDecoration: InputDecoration(
    labelText: 'เลือกจังหวัด',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.location_city),
  ),
  districtDecoration: InputDecoration(
    labelText: 'เลือกอำเภอ',
    border: OutlineInputBorder(),
  ),
  subDistrictDecoration: InputDecoration(
    labelText: 'เลือกตำบล',
    border: OutlineInputBorder(),
  ),
  zipCodeDecoration: InputDecoration(
    labelText: 'รหัสไปรษณีย์',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.mail),
  ),
  onChanged: (address) {
    // Handle address change
  },
)
```

### Initial Values

```dart
ThaiAddressForm(
  initialProvince: myProvince,
  initialDistrict: myDistrict,
  initialSubDistrict: mySubDistrict,
  onChanged: (address) {
    // Handle address change
  },
)
```

## Advanced Usage

### Use Data Only (Without UI Widgets)

You can use only the data and state management without the built-in widgets to create your own custom UI:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

class CustomAddressForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wait for data to load
    final initAsync = ref.watch(repositoryInitProvider);

    return initAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (_) => _buildCustomForm(ref),
    );
  }

  Widget _buildCustomForm(WidgetRef ref) {
    // Access repository directly
    final repository = ref.watch(thaiAddressRepositoryProvider);
    final state = ref.watch(thaiAddressNotifierProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    // Get all provinces
    final provinces = repository.provinces;

    // Get filtered districts based on selected province
    final districts = state.selectedProvince != null
        ? repository.getDistrictsByProvince(state.selectedProvince!.id)
        : <District>[];

    // Get filtered sub-districts based on selected district
    final subDistricts = state.selectedDistrict != null
        ? repository.getSubDistrictsByDistrict(state.selectedDistrict!.id)
        : <SubDistrict>[];

    return Column(
      children: [
        // Your custom province dropdown
        DropdownButton<Province>(
          value: state.selectedProvince,
          hint: Text('เลือกจังหวัด'),
          items: provinces.map((p) => DropdownMenuItem(
            value: p,
            child: Text(p.nameTh),
          )).toList(),
          onChanged: (province) {
            notifier.selectProvince(province);
          },
        ),

        // Your custom district dropdown
        DropdownButton<District>(
          value: state.selectedDistrict,
          hint: Text('เลือกอำเภอ'),
          items: districts.map((d) => DropdownMenuItem(
            value: d,
            child: Text(d.nameTh),
          )).toList(),
          onChanged: (district) {
            notifier.selectDistrict(district);
          },
        ),

        // Your custom sub-district dropdown
        DropdownButton<SubDistrict>(
          value: state.selectedSubDistrict,
          hint: Text('เลือกตำบล'),
          items: subDistricts.map((s) => DropdownMenuItem(
            value: s,
            child: Text(s.nameTh),
          )).toList(),
          onChanged: (subDistrict) {
            notifier.selectSubDistrict(subDistrict);
          },
        ),

        // Your custom zip code field
        TextField(
          decoration: InputDecoration(labelText: 'รหัสไปรษณีย์'),
          controller: TextEditingController(text: state.zipCode ?? ''),
          onChanged: (value) {
            notifier.setZipCode(value);
          },
        ),

        // Display selected address
        if (state.selectedProvince != null)
          Text('Address: ${state.toThaiAddress().provinceTh}'),
      ],
    );
  }
}
```

### Reverse Lookup: Zip Code → Auto-fill Address

กรอกรหัสไปรษณีย์เพื่อให้ระบบค้นหาและเติมข้อมูลตำบล, อำเภอ, จังหวัดโดยอัตโนมัติ:

```dart
class ZipCodeLookupWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ZipCodeLookupWidget> createState() => _ZipCodeLookupWidgetState();
}

class _ZipCodeLookupWidgetState extends ConsumerState<ZipCodeLookupWidget> {
  final _zipCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(thaiAddressNotifierProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    return Column(
      children: [
        // Zip code input field
        TextField(
          controller: _zipCodeController,
          decoration: InputDecoration(
            labelText: 'กรอกรหัสไปรษณีย์',
            hintText: 'เช่น 10110',
            helperText: 'ระบบจะค้นหาที่อยู่โดยอัตโนมัติ',
          ),
          keyboardType: TextInputType.number,
          maxLength: 5,
          onChanged: (zipCode) {
            // Automatically lookup and fill address
            notifier.setZipCode(zipCode);
          },
        ),

        SizedBox(height: 20),

        // Display auto-filled address
        if (state.selectedProvince != null) ...[
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ที่อยู่ที่พบ:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('จังหวัด: ${state.selectedProvince!.nameTh}'),
                  if (state.selectedDistrict != null)
                    Text('อำเภอ: ${state.selectedDistrict!.nameTh}'),
                  if (state.selectedSubDistrict != null)
                    Text('ตำบล: ${state.selectedSubDistrict!.nameTh}'),
                  Text('รหัสไปรษณีย์: ${state.zipCode}'),
                ],
              ),
            ),
          ),
        ],

        // Show error if zip code not found
        if (state.error != null)
          Text(
            state.error!,
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }
}
```

### Handle Multiple Sub-districts with Same Zip Code

บางรหัสไปรษณีย์มีหลายตำบล ให้ผู้ใช้เลือกเอง:

```dart
class ZipCodeWithMultipleOptions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(thaiAddressRepositoryProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    return TextField(
      decoration: InputDecoration(labelText: 'รหัสไปรษณีย์'),
      onChanged: (zipCode) {
        // Check if zip code has multiple sub-districts
        final subDistricts = repository.getSubDistrictsByZipCode(zipCode);

        if (subDistricts.length > 1) {
          // Show dialog to let user choose
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('เลือกตำบล'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: subDistricts.map((subDistrict) {
                  return ListTile(
                    title: Text(subDistrict.nameTh),
                    subtitle: Text(
                      '${repository.getDistrictById(subDistrict.districtId)?.nameTh}'
                    ),
                    onTap: () {
                      notifier.selectSubDistrict(subDistrict);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          // Single or no match - let notifier handle it
          notifier.setZipCode(zipCode);
        }
      },
    );
  }
}
```

### Direct Repository Access

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(thaiAddressRepositoryProvider);

    // Search provinces
    final provinces = repository.searchProvinces('กรุงเทพ');

    // Get districts by province
    final districts = repository.getDistrictsByProvince(provinceId);

    // Reverse lookup by zip code
    final subDistricts = repository.getSubDistrictsByZipCode('10110');

    return YourWidget();
  }
}
```

### Direct Notifier Access

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(thaiAddressNotifierProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    // Manually select province
    notifier.selectProvince(province);

    // Get current address
    final address = state.toThaiAddress();

    return YourWidget();
  }
}
```

## Data Model

```dart
class ThaiAddress {
  String? provinceTh;      // ชื่อจังหวัด (ไทย)
  String? provinceEn;      // Province name (English)
  int? provinceId;
  String? districtTh;      // ชื่ออำเภอ (ไทย)
  String? districtEn;      // District name (English)
  int? districtId;
  String? subDistrictTh;   // ชื่อตำบล (ไทย)
  String? subDistrictEn;   // Sub-district name (English)
  int? subDistrictId;
  String? zipCode;         // รหัสไปรษณีย์
  double? lat;             // ละติจูด
  double? long;            // ลองจิจูด
}
```

## Features in Detail

### 🔄 Cascading Selection

When you select a Province, Districts are automatically filtered. When you select a District, Sub-districts are automatically filtered. When you select a Sub-district, the Zip Code is automatically filled.

### 🔍 Reverse Lookup (Zip Code → Address)

Enter a Zip Code and the package will **automatically find and select** the corresponding:

- **ตำบล/แขวง** (Sub-district)
- **อำเภอ/เขต** (District)
- **จังหวัด** (Province)

**How it works:**

- If zip code is **unique** → All fields auto-filled instantly
- If zip code has **multiple sub-districts** → Zip code set, user can select manually
- If zip code is **invalid** → Error message shown

**Example:**

```dart
notifier.setZipCode('10110');
// Auto-fills: จังหวัดกรุงเทพมหานคร → เขตพระนคร → แขวงพระบรมมหาราชวัง
```

### 🧩 Use Without UI Widgets

You don't have to use the built-in `ThaiAddressForm` or `ThaiAddressPicker` widgets. Access the data directly:

```dart
// Get data only
final repository = ref.watch(thaiAddressRepositoryProvider);
final provinces = repository.provinces;
final districts = repository.getDistrictsByProvince(1);

// Create your own UI with the data
```

See **Advanced Usage** section for complete examples.

### 🚀 Performance Optimization

- JSON parsing happens in background isolates (using `compute`)
- Data is cached in memory after first load
- Indexed lookups for O(1) search performance
- Efficient filtering algorithms

## Requirements

- Flutter SDK: >=1.17.0
- Dart SDK: ^3.9.2

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you find this package helpful, please give it a ⭐ on GitHub!
