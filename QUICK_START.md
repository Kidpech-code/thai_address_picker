# 🚀 Quick Start Guide - Thai Address Picker

## ⚡ 30 Second Setup

### 1. Add Dependency

```yaml
dependencies:
  thai_address_picker: ^0.0.1
```

### 2. Wrap App

```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

### 3. Use Widget

```dart
ThaiAddressForm(
  onChanged: (address) => print(address.provinceTh),
)
```

---

## 🎯 Common Use Cases

### Form with All Fields

```dart
ThaiAddressForm(
  onChanged: (ThaiAddress address) {
    // Gets called on every change
    setState(() => _address = address);
  },
  useThai: true,  // Thai labels (default)
)
```

### Bottom Sheet Picker

```dart
final address = await ThaiAddressPicker.showBottomSheet(
  context: context,
  useThai: true,
);
if (address != null) {
  // User confirmed selection
}
```

### Dialog Picker

```dart
final address = await ThaiAddressPicker.showDialog(
  context: context,
  useThai: false,  // English labels
);
```

### Use Data Only (Custom UI)

```dart
class CustomForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(thaiAddressRepositoryProvider);
    final provinces = repo.provinces;

    // Build your own UI with the data
    return YourCustomDropdown(items: provinces);
  }
}
```

### Reverse Lookup (Zip → Address)

```dart
TextField(
  decoration: InputDecoration(labelText: 'รหัสไปรษณีย์'),
  onChanged: (zip) {
    // Auto-fills province, district, sub-district
    ref.read(thaiAddressNotifierProvider.notifier).setZipCode(zip);
  },
)

// Read auto-filled data
final state = ref.watch(thaiAddressNotifierProvider);
print('จังหวัด: ${state.selectedProvince?.nameTh}');
```

useThai: false, // English labels
);

````

---

## 🎨 Customization Cheat Sheet

### Custom Field Decoration

```dart
ThaiAddressForm(
  provinceDecoration: InputDecoration(
    labelText: 'เลือกจังหวัด',
    prefixIcon: Icon(Icons.location_city),
    border: OutlineInputBorder(),
  ),
  // ... same for district, subDistrict, zipCode
)
````

### Custom Text Style

```dart
ThaiAddressForm(
  textStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)
```

### With Initial Values

```dart
ThaiAddressForm(
  initialProvince: myProvince,
  initialDistrict: myDistrict,
  initialSubDistrict: mySubDistrict,
  onChanged: (address) => saveAddress(address),
)
```

---

## 🔧 Advanced Features

### Manual State Control

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    // Manual selection
    notifier.selectProvince(province);
    notifier.setZipCode('10110');

    // Read current state
    final state = ref.watch(thaiAddressNotifierProvider);
    final currentProvince = state.selectedProvince;

    return YourWidget();
  }
}
```

### Direct Repository Access

```dart
final repository = ref.watch(thaiAddressRepositoryProvider);

// Search
final provinces = repository.searchProvinces('กรุงเทพ');
final districts = repository.getDistrictsByProvince(1);

// Reverse lookup
final subDistricts = repository.getSubDistrictsByZipCode('10110');
```

### Wait for Initialization

```dart
final init = ref.watch(repositoryInitProvider);

return init.when(
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
  data: (_) => ThaiAddressForm(...),
);
```

---

## 📊 Data Model Reference

### ThaiAddress (Output)

```dart
ThaiAddress {
  String? provinceTh;      // "กรุงเทพมหานคร"
  String? provinceEn;      // "Bangkok"
  int? provinceId;         // 1
  String? districtTh;      // "พระนคร"
  String? districtEn;      // "Phra Nakhon"
  int? districtId;         // 1001
  String? subDistrictTh;   // "พระบรมมหาราชวัง"
  String? subDistrictEn;   // "Phra Borom Maha Ratchawang"
  int? subDistrictId;      // 100101
  String? zipCode;         // "10200"
  double? lat;             // 13.7563
  double? long;            // 100.4935
}
```

---

## 🎓 Key Concepts

### Cascading Selection

1. Select **Province** → Districts filtered
2. Select **District** → Sub-districts filtered
3. Select **Sub-district** → Zip code auto-filled

### Reverse Lookup

- Type **Zip Code** → Auto-select address (if unique)
- Multiple sub-districts? → Zip set, user selects manually

### Performance

- ✅ JSON parsed in background (Isolates)
- ✅ Data cached in memory
- ✅ Instant lookups (O(1) indexed)

---

## 🐛 Troubleshooting

### "Repository not initialized"

```dart
// Wrap your app with ProviderScope
ProviderScope(child: MyApp())

// Or wait for initialization
ref.watch(repositoryInitProvider)
```

### Dropdown is empty

```dart
// Select parent first
// 1. Select Province before District
// 2. Select District before Sub-district
```

### Asset not found

```dart
// Package handles assets automatically
// Just ensure pubspec.yaml is correct
```

---

## 📚 Resources

- **README.md** - Overview & installation
- **USAGE.md** - Detailed examples
- **CHANGELOG.md** - Version history
- **example/** - Working demo app

---

## 💡 Pro Tips

1. **Language Toggle**: Set `useThai: false` for English
2. **Form Validation**: Check all fields in `onChanged`
3. **Search**: Use repository methods for custom search UI
4. **State Persistence**: Save ThaiAddress to local storage
5. **Coordinates**: Use lat/long for map integration

---

**Happy Coding! 🎉**
