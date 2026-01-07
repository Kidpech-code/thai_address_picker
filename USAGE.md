## Package Usage Instructions

### 📋 Complete Setup Guide

#### 1. Installation

```yaml
dependencies:
  thai_address_picker: ^0.0.1
```

Run:

```bash
flutter pub get
```

#### 2. Wrap Your App

```dart
import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

void main() {
  runApp(
    const ProviderScope(  // 👈 Required!
      child: MyApp(),
    ),
  );
}
```

#### 3. Four Ways to Use

##### Option A: Inline Form Widget

```dart
ThaiAddressForm(
  onChanged: (ThaiAddress address) {
    print('Province: ${address.provinceTh}');
    print('Zip Code: ${address.zipCode}');
  },
)
```

##### Option B: Bottom Sheet Picker

```dart
final address = await ThaiAddressPicker.showBottomSheet(
  context: context,
  useThai: true,
);
```

##### Option C: Dialog Picker

```dart
final address = await ThaiAddressPicker.showDialog(
  context: context,
  useThai: true,
);
```

##### Option D: Use Data Only (No UI Widgets)

```dart
// Access data directly to build your own UI
class CustomAddressWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(thaiAddressRepositoryProvider);
    final provinces = repository.provinces;

    // Build your own dropdown/autocomplete/whatever UI
    return YourCustomWidget(data: provinces);
  }
}
```

### 🎨 Customization Examples

#### Custom Styling

```dart
ThaiAddressForm(
  textStyle: TextStyle(fontSize: 16, color: Colors.blue),
  provinceDecoration: InputDecoration(
    labelText: 'เลือกจังหวัด',
    prefixIcon: Icon(Icons.location_city),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  // ... other decorations
)
```

#### With Initial Values

```dart
ThaiAddressForm(
  initialProvince: selectedProvince,
  initialDistrict: selectedDistrict,
  initialSubDistrict: selectedSubDistrict,
  onChanged: (address) => print(address),
)
```

### 🔧 Advanced Usage

#### Direct State Management

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the notifier
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    // Manually trigger selection
    notifier.selectProvince(myProvince);
    notifier.setZipCode('10110');

    // Watch state changes
    final state = ref.watch(thaiAddressNotifierProvider);
    print('Current province: ${state.selectedProvince?.nameTh}');

    return YourWidget();
  }
}
```

#### Direct Repository Access

```dart
class SearchWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(thaiAddressRepositoryProvider);

    // Wait for initialization
    final init = ref.watch(repositoryInitProvider);

    return init.when(
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (_) {
        // Search operations
        final provinces = repository.searchProvinces('กรุงเทพ');
        final subDistricts = repository.getSubDistrictsByZipCode('10110');

        return YourSearchUI();
      },
    );
  }
}
```

### � Reverse Lookup: Zip Code → Address

#### Simple Reverse Lookup

```dart
class ZipCodeFirstForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<ZipCodeFirstForm> createState() => _ZipCodeFirstFormState();
}

class _ZipCodeFirstFormState extends ConsumerState<ZipCodeFirstForm> {
  final _zipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(thaiAddressNotifierProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    return Column(
      children: [
        // 1. กรอกรหัสไปรษณีย์ก่อน
        TextField(
          controller: _zipController,
          decoration: InputDecoration(
            labelText: 'รหัสไปรษณีย์',
            hintText: 'กรอก 5 หลัก เช่น 10110',
          ),
          keyboardType: TextInputType.number,
          maxLength: 5,
          onChanged: (zip) {
            // 2. ระบบจะค้นหาและเติมที่อยู่โดยอัตโนมัติ
            notifier.setZipCode(zip);
          },
        ),

        SizedBox(height: 20),

        // 3. แสดงผลลัพธ์ที่ค้นพบ
        if (state.selectedProvince != null) ...[
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✓ พบที่อยู่',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    )
                  ),
                  Divider(),
                  _buildInfoRow('จังหวัด', state.selectedProvince!.nameTh),
                  _buildInfoRow('อำเภอ', state.selectedDistrict?.nameTh),
                  _buildInfoRow('ตำบล', state.selectedSubDistrict?.nameTh),
                  _buildInfoRow('รหัสไปรษณีย์', state.zipCode),
                ],
              ),
            ),
          ),
        ] else if (state.error != null) ...[
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '✗ ${state.error}',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:')),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
```

#### Handle Multiple Sub-districts

บางรหัสไปรษณีย์มีหลายตำบล:

```dart
TextField(
  decoration: InputDecoration(labelText: 'รหัสไปรษณีย์'),
  onChanged: (zipCode) {
    final repository = ref.read(thaiAddressRepositoryProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);
    final subDistricts = repository.getSubDistrictsByZipCode(zipCode);

    if (subDistricts.length > 1) {
      // แสดง dialog ให้เลือก
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('พบหลายตำบล กรุณาเลือก'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: subDistricts.map((sub) {
              final district = repository.getDistrictById(sub.districtId);
              return ListTile(
                title: Text(sub.nameTh),
                subtitle: Text('${district?.nameTh}'),
                onTap: () {
                  notifier.selectSubDistrict(sub);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      );
    } else {
      // เฉพาะตำบลเดียว หรือไม่พบ
      notifier.setZipCode(zipCode);
    }
  },
)
```

### �📊 Data Models

#### ThaiAddress (Output Model)

```dart
class ThaiAddress {
  String? provinceTh;       // "กรุงเทพมหานคร"
  String? provinceEn;       // "Bangkok"
  int? provinceId;          // 1
  String? districtTh;       // "พระนคร"
  String? districtEn;       // "Phra Nakhon"
  int? districtId;          // 1001
  String? subDistrictTh;    // "พระบรมมหาราชวัง"
  String? subDistrictEn;    // "Phra Borom Maha Ratchawang"
  int? subDistrictId;       // 100101
  String? zipCode;          // "10200"
  double? lat;              // 13.7563
  double? long;             // 100.4935
}
```

### 🚀 Performance Features

- ✅ JSON parsing in isolates (non-blocking UI)
- ✅ In-memory caching (single load)
- ✅ Indexed lookups (O(1) complexity)
- ✅ Efficient filtering algorithms
- ✅ Debounce-friendly design

### 💡 Tips

1. **Zip Code Auto-fill**: When user selects a sub-district, zip code fills automatically
2. **Reverse Lookup**: Type zip code to auto-select address (if unique)
3. **Multiple Sub-districts**: Some zip codes belong to multiple sub-districts
4. **Bilingual Support**: All data includes both Thai and English names
5. **Coordinates**: Sub-districts include latitude/longitude for mapping

### 🔍 Common Use Cases

#### Form Validation

```dart
ThaiAddressForm(
  onChanged: (address) {
    if (address.zipCode != null &&
        address.provinceTh != null &&
        address.districtTh != null &&
        address.subDistrictTh != null) {
      // All fields filled - form is valid
      submitForm(address);
    }
  },
)
```

#### Search by Text

```dart
final notifier = ref.read(thaiAddressNotifierProvider.notifier);
final provinces = notifier.searchProvinces('กรุง'); // Fuzzy search
final districts = notifier.searchDistricts('บาง'); // Filtered by selected province
```

#### Check if Initialized

```dart
ref.watch(repositoryInitProvider).when(
  loading: () => LoadingScreen(),
  error: (e, _) => ErrorScreen(e),
  data: (_) => YourMainApp(),
);
```

### 🐛 Troubleshooting

**Problem**: "ThaiAddressRepository is not initialized"
**Solution**: Wrap your widget with `ProviderScope` or wait for `repositoryInitProvider`

**Problem**: Asset not found
**Solution**: Ensure your app's `pubspec.yaml` references the package correctly

**Problem**: Dropdown is empty
**Solution**: Make sure you've selected the parent field first (Province before District)
