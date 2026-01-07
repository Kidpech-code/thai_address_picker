# Thai Address Picker 🇹🇭

A high-performance Flutter package for Thai address selection with Province (จังหวัด), District (อำเภอ/เขต), Sub-district (ตำบล/แขวง), and Zip Code (รหัสไปรษณีย์) support.

## Features ✨

- 🚀 **High Performance**: Uses Isolates for background JSON parsing
- 🔄 **Cascading Selection**: Province → District → Sub-district → Auto-fill Zip Code
- 🔍 **Reverse Lookup**: Enter Zip Code → Auto-fill address
- 🎨 **Customizable UI**: Full control over styling and decoration
- 📦 **State Management**: Built with Riverpod for clean architecture
- 💾 **Caching**: Data loaded once and cached in memory
- 🌐 **Bilingual**: Thai and English support

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  thai_address_picker: ^0.0.1
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

### 🔍 Reverse Lookup

Enter a Zip Code and the package will automatically find and select the corresponding Province, District, and Sub-district. Note: Some zip codes may belong to multiple sub-districts.

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
