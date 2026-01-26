# Thai Address Picker 🇹🇭

![Coverage](https://img.shields.io/badge/coverage-98%25-brightgreen)

A high-performance Flutter package for Thai address selection with Province (จังหวัด), District (อำเภอ/เขต), Sub-district (ตำบล/แขวง), Village (หมู่บ้าน), and Zip Code (รหัสไปรษณีย์) support.

## Features ✨

- 🚀 **High Performance**: Uses Isolates for background JSON parsing
- 🔄 **Cascading Selection**: Province → District → Sub-district → Auto-fill Zip Code
- 🔍 **Reverse Lookup**: Enter Zip Code → Auto-fill Sub-district, District, Province
- ✨ **Zip Code Autocomplete**: Real-time suggestions with full address preview
- 🏘️ **Village Autocomplete**: Real-time village search with Moo number (NEW in v0.3.0)
- 🎯 **Multi-Area Support**: Handles zip codes with multiple locations (e.g., 10200)
- 🎨 **Customizable UI**: Full control over styling and decoration
- 🧩 **Flexible**: Use built-in widgets OR just data/state for your own UI
- 📦 **State Management**: Built with Riverpod for clean architecture
- 💾 **Caching**: Data loaded once and cached in memory
- 🌐 **Bilingual**: Thai and English support

## Screenshots 📸

<p align="center">
  <img src="https://raw.githubusercontent.com/Kidpech-code/thai_address_picker/main/assets/images/screenshot_1.png" width="200" />
  <img src="https://raw.githubusercontent.com/Kidpech-code/thai_address_picker/main/assets/images/screenshot_2.png" width="200" />
  <img src="https://raw.githubusercontent.com/Kidpech-code/thai_address_picker/main/assets/images/screenshot_3.png" width="200" />
  <img src="https://raw.githubusercontent.com/Kidpech-code/thai_address_picker/main/assets/images/screenshot_4.png" width="200" />
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/Kidpech-code/thai_address_picker/main/assets/images/screenshot_5.png" width="200" />
  <img src="https://raw.githubusercontent.com/Kidpech-code/thai_address_picker/main/assets/images/screenshot_6.png" width="200" />
  <img src="https://raw.githubusercontent.com/Kidpech-code/thai_address_picker/main/assets/images/screenshot_7.png" width="200" />
  <img src="https://raw.githubusercontent.com/Kidpech-code/thai_address_picker/main/assets/images/screenshot_8.png" width="200" />
</p>

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  thai_address_picker: ^1.0.4
```

---

### 📊 Quick Decision Table (เลือกแบบใหน)

| สถานการณ์                      | ต้อง `ProviderScope` ?  | ตัวอย่าง   | โค้ดที่ต้อง  | ความยุ่งยาก            | Performance   |
| ------------------------------ | ----------------------- | ---------- | ------------ | ---------------------- | ------------- |
| ⭐ **Standalone** (แนะนำ!)     | ❌ **ไม่ต้อง**          | Scenario 0 | 10 บรรทัด    | ⭐ ง่าย                | 🚀 **สูงสุด** |
| ใช้ `ThaiAddressForm` widget   | ✅ **ต้อง**             | Scenario 1 | 5 บรรทัด     | ⭐ ง่ายที่สุด          | ⚡ สูง        |
| ใช้ `ThaiAddressPicker` widget | ✅ **ต้อง**             | Scenario 1 | 5 บรรทัด     | ⭐ ง่ายที่สุด          | ⚡ สูง        |
| ใช้ `ZipCodeAutocomplete`      | ✅ **ต้อง**             | Scenario 5 | 5 บรรทัด     | ⭐ ง่ายที่สุด          | ⚡ สูง        |
| ใช้ repository แบบ stateless   | ❌ **ไม่ต้อง**          | Scenario 2 | 10-20 บรรทัด | ⭐⭐ ปานกลาง           | ⚡ สูง        |
| ใช้กับ Provider/GetX           | ✅ **ต้อง** (wrap ด้วย) | Scenario 3 | 10-15 บรรทัด | ⭐⭐ ปานกลาง           | ⚡ สูง        |
| Advanced: Riverpod only        | ✅ **ต้อง**             | Scenario 4 | 15-25 บรรทัด | ⭐⭐⭐ ค่อนข้างซับซ้อน | ⚡ สูง        |

**🏆 แนะนำ:** Scenario 0 (Standalone) ถ้าต้องการ performance สูงสุดและไม่ต้องการ state management

---

### 🔗 Full Integration Example (ใช้ได้เลย!)

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

void main() {
  runApp(
    ProviderScope(  // Riverpod (thai_address_picker)
      child: MultiProvider(  // Provider (state management ของคุณ)
        providers: [
          ChangeNotifierProvider(create: (_) => AddressFormState()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

// address_form_state.dart
class AddressFormState extends ChangeNotifier {
  ThaiAddress? _selectedAddress;

  ThaiAddress? get selectedAddress => _selectedAddress;

  void selectAddress(ThaiAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }
}

// address_form_screen.dart
class AddressFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ฟอร์มกรอกที่อยู่')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer2<AddressFormState>(
          builder: (context, addressState, _) {
            return Column(
              children: [
                ThaiAddressForm(
                  onChanged: (address) {
                    addressState.selectAddress(address);
                  },
                  useThai: true,
                ),
                const SizedBox(height: 20),
                if (addressState.selectedAddress != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ที่อยู่ที่เลือก:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('จังหวัด: ${addressState.selectedAddress?.provinceTh}'),
                          Text('อำเภอ: ${addressState.selectedAddress?.districtTh}'),
                          Text('ตำบล: ${addressState.selectedAddress?.subDistrictTh}'),
                          Text('รหัสไปรษณีย์: ${addressState.selectedAddress?.zipCode}'),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

---

## Usage

### 1. Setup: Wrap your app with ProviderScope (⚠️ When Required)

**⚡ ProviderScope จำเป็นต้องใช้เมื่อ:**

- ใช้ widget ที่รวม UI (`ThaiAddressForm`, `ThaiAddressPicker`, `ZipCodeAutocomplete`, `VillageAutocomplete`)
- ใช้ `thaiAddressNotifierProvider` สำหรับ state management
- ใช้ Riverpod provider โดยตรง

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

**✅ ไม่ต้องใช้ ProviderScope เมื่อ:**

- ใช้เฉพาะ `repository` สำหรับ data access โดยไม่ใช้ state management
- สร้าง UI เองโดยใช้ `ThaiAddressRepository` แบบ stateless

```dart
// ❌ ไม่ต้องใช้ ProviderScope ถ้าแบบนี้
void main() {
  runApp(const MyApp());
}

// ใน widget คุณสามารถใช้ได้:
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // สร้าง repository เอง
    final repository = ThaiAddressRepository();
    // ...
  }
}
```

**🔗 ใช้ร่วมกับ State Management อื่นได้ไหม?**

**ได้เลย!** Riverpod ไม่ขัดแย้งกับ state management อื่นๆ เช่น:

```dart
// ✅ ใช้ได้ - ประมาณนี้
void main() {
  runApp(
    ProviderScope(  // Riverpod (thai_address_picker)
      child: MultiProvider(  // Provider (state management อื่น)
        providers: [
          ChangeNotifierProvider(create: (_) => MyAppState()),
          ChangeNotifierProvider(create: (_) => AnotherNotifier()),
          // ...
        ],
        child: const MyApp(),
      ),
    ),
  );
}
```

สามารถใช้ได้กับ:

- ✅ Provider (provider package)
- ✅ GetX
- ✅ BLoC / Cubit
- ✅ MobX
- ✅ Redux
- ✅ Riverpod เพียงอย่างเดียว (แน่นอน!)

---

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

### 6. Use Village Autocomplete (NEW 🏘️)

Real-time village (หมู่บ้าน) search with Moo number:

```dart
import 'package:thai_address_picker/thai_address_picker.dart';

class MyForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VillageAutocomplete(
      decoration: InputDecoration(
        labelText: 'หมู่บ้าน',
        hintText: 'พิมพ์ชื่อหมู่บ้าน',
        helperText: 'ระบบจะแนะนำหมู่บ้านอัตโนมัติ',
      ),
      onVillageSelected: (Village village) {
        // Auto-filled! All address fields are updated
        print('Village: ${village.nameTh}');
        print('Moo: ${village.mooNo}');

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

- 🏘️ Search from first character typed
- 🔍 Substring matching for flexible search (e.g., "บ้าน" matches all villages)
- 📍 Displays: Village • หมู่ที่ • SubDistrict • District • Province
- 🎯 Shows Moo number (หมู่ที่) for accurate identification
- 🔄 Auto-fills all address fields when selected
- ⚡ High-performance O(k) search with early exit

## 🎯 Usage Scenarios (เลือกตามความต้องการของคุณ)

### 🚀 Scenario 0: Standalone - Pure Repository (แนะนำ! ประสิทธิภาพสูงสุด)

**ไม่ต้องพึ่งพา state management เลย!** ใช้ได้ทันทีโดยไม่ต้อง wrap อะไร

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

void main() {
  runApp(const MyApp());  // ❌ ไม่ต้อง ProviderScope
}

// address_screen.dart
class AddressScreen extends StatefulWidget {
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  // Singleton - auto-cached, O(1) lookup
  late ThaiAddressRepository _repository;

  Province? _selectedProvince;
  District? _selectedDistrict;
  SubDistrict? _selectedSubDistrict;

  @override
  void initState() {
    super.initState();
    _repository = ThaiAddressRepository();
    _initRepository();
  }

  Future<void> _initRepository() async {
    await _repository.initialize();  // Isolate-based, non-blocking
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_repository.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Column(
      children: [
        // Province - O(1) access
        DropdownButton<Province>(
          value: _selectedProvince,
          items: _repository.provinces.map((p) {
            return DropdownMenuItem(value: p, child: Text(p.nameTh));
          }).toList(),
          onChanged: (province) {
            setState(() {
              _selectedProvince = province;
              _selectedDistrict = null;
              _selectedSubDistrict = null;
            });
          },
        ),

        // District - O(1) lookup + filtering
        if (_selectedProvince != null)
          DropdownButton<District>(
            value: _selectedDistrict,
            items: _repository
                .getDistrictsByProvince(_selectedProvince!.id)
                .map((d) {
              return DropdownMenuItem(value: d, child: Text(d.nameTh));
            }).toList(),
            onChanged: (district) {
              setState(() {
                _selectedDistrict = district;
                _selectedSubDistrict = null;
              });
            },
          ),
      ],
    );
  }
}
```

**🔥 Autocomplete - Zip Code & Village (Built-in Algorithm)**

```dart
class ZipCodeAutocompleteStandalone extends StatefulWidget {
  @override
  State<ZipCodeAutocompleteStandalone> createState() => _ZipCodeAutocompleteStandaloneState();
}

class _ZipCodeAutocompleteStandaloneState extends State<ZipCodeAutocompleteStandalone> {
  final _repository = ThaiAddressRepository();
  List<ZipCodeSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _repository.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'รหัสไปรษณีย์',
            hintText: 'พิมพ์ เช่น 10110',
          ),
          onChanged: (query) {
            // High-performance search - prefix matching + early exit
            final suggestions = _repository.searchZipCodes(
              query,
              maxResults: 10,  // Early exit after 10 results
            );
            setState(() => _suggestions = suggestions);
          },
        ),
        // Display suggestions
        ListView.builder(
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final s = _suggestions[index];
            return ListTile(
              title: Text(s.displayText),  // "10110 • พระบรมมหาราชวัง • พระนคร • กรุงเทพมหานคร"
              subtitle: Text(s.displayTextEn),
              onTap: () {
                // Auto-filled! All data available
                print('Province: ${s.province?.nameTh}');
                print('District: ${s.district?.nameTh}');
                print('SubDistrict: ${s.subDistrict.nameTh}');
              },
            );
          },
        ),
      ],
    );
  }
}
```

**🏘️ Village Autocomplete (~70,000 villages)**

```dart
class VillageAutocompleteStandalone extends StatefulWidget {
  @override
  State<VillageAutocompleteStandalone> createState() => _VillageAutocompleteStandaloneState();
}

class _VillageAutocompleteStandaloneState extends State<VillageAutocompleteStandalone> {
  final _repository = ThaiAddressRepository();
  List<VillageSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _repository.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'หมู่บ้าน',
            hintText: 'พิมพ์ชื่อหมู่บ้าน',
          ),
          onChanged: (query) {
            // Substring matching - O(k) where k = number of results
            final suggestions = _repository.searchVillages(
              query,
              maxResults: 15,
            );
            setState(() => _suggestions = suggestions);
          },
        ),
        // Display suggestions
        ListView.builder(
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final s = _suggestions[index];
            return ListTile(
              leading: const Icon(Icons.home),
              title: Text(s.village.nameTh),
              subtitle: Text('${s.displayMoo} • ${s.subDistrict?.nameTh}'),
              trailing: Text(s.district?.nameTh ?? ''),
              onTap: () {
                // All address data available
                print('Village: ${s.village.nameTh}');
                print('Moo: ${s.village.mooNo}');
                print('Province: ${s.province?.nameTh}');
              },
            );
          },
        ),
      ],
    );
  }
}
```

**✨ ข้อดี:**

- ✅ **ไม่ต้อง ProviderScope** ❌
- ✅ **ไม่ต้อง state management** (Riverpod/Provider/GetX/BLoC)
- ✅ **ไม่ต้อง widget ของเรา** - สร้าง UI เอง
- ✅ **Maximum Performance**: Singleton + O(1) HashMap + Isolate parsing
- ✅ **Algorithm ที่ดีที่สุด**: Early exit + Indexed lookup
- ✅ **Built-in Autocomplete**: ZipCodeSuggestion + VillageSuggestion classes

**📊 Performance:**

- Province/District/SubDistrict lookup: **O(1)** (HashMap)
- Zip Code search: **O(k)** with early exit (k = maxResults)
- Village search: **O(k)** with early exit
- Data loading: **Non-blocking** (Isolate)
- Memory: **Cached** (loaded once)

**🎯 เหมาะสำหรับ:**

- ไม่อยากใช้ state management เลย
- ต้องการ performance สูงสุด
- ต้องการควบคุม UI เอง 100%
- แอปที่มี state management อื่นอยู่แล้ว

**🔗 ดูตัวอย่างเต็ม:** `example/lib/standalone_usage_example.dart`

---

### ✨ Scenario 1: ใช้ Widget แบบปกติ + ProviderScope (ใช้ง่ายที่สุด)

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AddressScreen(),
    );
  }
}

// address_screen.dart
class AddressScreen extends StatelessWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('กรอกที่อยู่')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ThaiAddressForm(
          onChanged: (address) {
            print('จังหวัด: ${address.provinceTh}');
            print('อำเภอ: ${address.districtTh}');
            print('ตำบล: ${address.subDistrictTh}');
            print('รหัสไปรษณีย์: ${address.zipCode}');
          },
          useThai: true,
        ),
      ),
    );
  }
}
```

**ข้อดี:**

- ✅ ใช้งานง่าย - เพียงแค่ wrap ด้วย `ProviderScope`
- ✅ State management ถูก handle โดยแพ็คเกจ
- ✅ ไม่ต้องเขียน boilerplate code
- ✅ Real-time validation

**เหมาะสำหรับ:**

- หน้าฟอร์มไทย
- ไม่มีความต้องการ state management ที่ซับซ้อน

---

### 🔧 Scenario 2: ใช้ Repository แบบ Stateless (ไม่ต้อง ProviderScope)

หากคุณต้องการแค่ data โดยไม่ต้องการ state management ของแพ็คเกจ:

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

void main() {
  runApp(const MyApp());  // ❌ ไม่ต้อง ProviderScope
}

// custom_address_form.dart
class CustomAddressForm extends StatefulWidget {
  @override
  State<CustomAddressForm> createState() => _CustomAddressFormState();
}

class _CustomAddressFormState extends State<CustomAddressForm> {
  final repository = ThaiAddressRepository();

  String? selectedProvinceId;
  String? selectedDistrictId;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  void _initRepository() async {
    await repository.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!repository.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // DropdownButton จังหวัด
        DropdownButton<Province>(
          hint: const Text('เลือกจังหวัด'),
          items: repository.provinces.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Text(p.nameTh),
            );
          }).toList(),
          onChanged: (province) {
            setState(() => selectedProvinceId = province?.id.toString());
          },
        ),

        // DropdownButton อำเภอ
        if (selectedProvinceId != null)
          DropdownButton<District>(
            hint: const Text('เลือกอำเภอ'),
            items: repository
                .getDistrictsByProvince(int.parse(selectedProvinceId!))
                .map((d) {
              return DropdownMenuItem(
                value: d,
                child: Text(d.nameTh),
              );
            }).toList(),
            onChanged: (district) {
              setState(() => selectedDistrictId = district?.id.toString());
            },
          ),
      ],
    );
  }
}
```

**ข้อดี:**

- ✅ ไม่ต้อง Riverpod / ProviderScope
- ✅ ใช้ state management ที่มีอยู่แล้ว (setState, Provider, BLoC, etc.)
- ✅ ควบคุมได้เต็มที่

**เหมาะสำหรับ:**

- แอปที่ใช้ state management อื่น
- ต้องการ UI ที่custom มาก

---

### 🚀 Scenario 3: ใช้ร่วมกับ Provider / GetX / BLoC

```dart
// main.dart - ใช้ได้กับ Provider
void main() {
  runApp(
    ProviderScope(  // Riverpod สำหรับ thai_address_picker
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MyAppState()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

// MyAppState - state management ของคุณ
class MyAppState extends ChangeNotifier {
  ThaiAddress? _selectedAddress;

  ThaiAddress? get selectedAddress => _selectedAddress;

  void updateAddress(ThaiAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }
}

// ใน widget
class AddressFormWithProvider extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = Provider.of<MyAppState>(context);

    return ThaiAddressForm(
      onChanged: (address) {
        // ส่งไปที่ Provider
        appState.updateAddress(address);
      },
      useThai: true,
    );
  }
}
```

**ข้อดี:**

- ✅ ใช้ Riverpod + state management อื่นได้
- ✅ ไม่มี conflict
- ✅ แยก concerns ได้ดี

---

### 🎨 Scenario 4: ใช้ Riverpod เพียงอย่างเดียว (Advanced)

```dart
// custom_notifier.dart
class AddressFormNotifier extends Notifier<ThaiAddress?> {
  @override
  ThaiAddress? build() => null;

  void updateAddress(ThaiAddress address) {
    state = address;
  }
}

final addressFormProvider = NotifierProvider<AddressFormNotifier, ThaiAddress?>(
  AddressFormNotifier.new,
);

// main.dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// widget
class AddressFormScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAddress = ref.watch(addressFormProvider);

    return Scaffold(
      body: Column(
        children: [
          ThaiAddressForm(
            onChanged: (address) {
              ref.read(addressFormProvider.notifier).updateAddress(address);
            },
          ),
          if (selectedAddress != null)
            Text('เลือก: ${selectedAddress.provinceTh}'),
        ],
      ),
    );
  }
}
```

---

### 🔍 Scenario 5: Reverse Lookup + State Management

```dart
// ตัวอย่างการใช้รหัสไปรษณีย์
class ZipCodeLookupWithState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ZipCodeAutocomplete(
      decoration: InputDecoration(
        labelText: 'รหัสไปรษณีย์',
        hintText: 'พิมพ์รหัส เช่น 10110',
      ),
      onZipCodeSelected: (zipCode) {
        // อัตโนมัติ auto-fill
        final state = ref.read(thaiAddressNotifierProvider);

        print('พบ: ${state.selectedProvince?.nameTh}');
        print('${state.selectedDistrict?.nameTh}');
        print('${state.selectedSubDistrict?.nameTh}');

        // ส่งต่อไปที่ provider ของคุณ
        ref.read(addressFormProvider.notifier).updateAddress(
          state.toThaiAddress(),
        );
      },
    );
  }
}
```

---

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

### Disable Zip Code Autocomplete

You can disable zip code autocomplete suggestions and use a simple TextField instead:

```dart
ThaiAddressForm(
  // Disable autocomplete for simpler UI
  showZipCodeAutocomplete: false,
  onChanged: (address) {
    // Handle address change
  },
)
```

**Why disable autocomplete?**

- ✅ Simpler UI when suggestions are not needed
- ✅ Faster performance for basic input
- ✅ Better for forms where users already know their zip code
- ✅ Less visual clutter

**Comparison:**

| Feature                  | With Autocomplete (`true`) | Without Autocomplete (`false`) |
| ------------------------ | -------------------------- | ------------------------------ |
| Suggestions while typing | ✅ Yes                     | ❌ No                          |
| Auto-fill address        | ✅ Yes                     | ❌ No                          |
| Multi-area support       | ✅ Yes                     | ❌ No                          |
| UI Complexity            | More features              | Simpler                        |
| Performance              | Good                       | Better                         |

**Examples:**

- [`disable_zipcode_autocomplete_example.dart`](example/lib/disable_zipcode_autocomplete_example.dart) - Basic example with disabled autocomplete
- [`compare_zipcode_modes_example.dart`](example/lib/compare_zipcode_modes_example.dart) - Side-by-side comparison

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

You can use only the data and state management without the built-in widgets to create your own custom UI. This is perfect for advanced customization or integration with other UI frameworks.

#### 1. Basic Cascading Dropdowns

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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
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

    // Get zip codes by sub-district
    final zipCodes = state.selectedSubDistrict != null
        ? repository.getZipCodesBySubDistrict(state.selectedSubDistrict!.id)
        : <String>[];

    return Column(
      children: [
        // Province dropdown
        DropdownButton<Province>(
          value: state.selectedProvince,
          hint: const Text('เลือกจังหวัด'),
          isExpanded: true,
          items: provinces.map((p) => DropdownMenuItem(
            value: p,
            child: Text(p.nameTh),
          )).toList(),
          onChanged: (province) {
            if (province != null) {
              notifier.selectProvince(province);
            }
          },
        ),

        const SizedBox(height: 12),

        // District dropdown
        DropdownButton<District>(
          value: state.selectedDistrict,
          hint: const Text('เลือกอำเภอ'),
          isExpanded: true,
          items: districts.map((d) => DropdownMenuItem(
            value: d,
            child: Text(d.nameTh),
          )).toList(),
          onChanged: (district) {
            if (district != null) {
              notifier.selectDistrict(district);
            }
          },
        ),

        const SizedBox(height: 12),

        // Sub-district dropdown
        DropdownButton<SubDistrict>(
          value: state.selectedSubDistrict,
          hint: const Text('เลือกตำบล'),
          isExpanded: true,
          items: subDistricts.map((s) => DropdownMenuItem(
            value: s,
            child: Text(s.nameTh),
          )).toList(),
          onChanged: (subDistrict) {
            if (subDistrict != null) {
              notifier.selectSubDistrict(subDistrict);
            }
          },
        ),

        const SizedBox(height: 12),

        // Zip code field
        TextField(
          decoration: const InputDecoration(
            labelText: 'รหัสไปรษณีย์',
            hintText: 'เช่น 10110',
          ),
          controller: TextEditingController(text: state.zipCode ?? ''),
          onChanged: (value) {
            notifier.setZipCode(value);
          },
        ),

        const SizedBox(height: 12),

        // Display selected address
        if (state.selectedProvince != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ที่อยู่ที่เลือก:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('จังหวัด: ${state.selectedProvince!.nameTh}'),
                  if (state.selectedDistrict != null)
                    Text('อำเภอ: ${state.selectedDistrict!.nameTh}'),
                  if (state.selectedSubDistrict != null)
                    Text('ตำบล: ${state.selectedSubDistrict!.nameTh}'),
                  if (state.zipCode != null)
                    Text('รหัสไปรษณีย์: ${state.zipCode}'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
```

#### 2. Advanced: Custom Search with Providers

Combine repository data with custom providers for complex filtering:

```dart
// Create a custom search provider
final searchResultsProvider = StateNotifierProvider<SearchNotifier, List<SubDistrict>>((ref) {
  return SearchNotifier(ref.watch(thaiAddressRepositoryProvider));
});

class SearchNotifier extends StateNotifier<List<SubDistrict>> {
  final ThaiAddressRepository repository;

  SearchNotifier(this.repository) : super([]);

  void search(String query) {
    if (query.isEmpty) {
      state = [];
      return;
    }

    // Search across all sub-districts
    final results = repository.provinces
        .expand((p) => repository.getDistrictsByProvince(p.id))
        .expand((d) => repository.getSubDistrictsByDistrict(d.id))
        .where((s) => s.nameTh.toLowerCase().contains(query.toLowerCase()))
        .toList();

    state = results;
  }
}

class SearchWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);
    final notifier = ref.read(searchResultsProvider.notifier);
    final addressNotifier = ref.read(thaiAddressNotifierProvider.notifier);

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'ค้นหาตำบล',
            hintText: 'พิมพ์ชื่อตำบล',
          ),
          onChanged: (query) {
            notifier.search(query);
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final subDistrict = results[index];
              return ListTile(
                title: Text(subDistrict.nameTh),
                subtitle: Text('ID: ${subDistrict.id}'),
                onTap: () {
                  addressNotifier.selectSubDistrict(subDistrict);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
```

#### 3. Village Data Access Without Widgets

Get and search village data directly from repository:

```dart
class VillageDataAccessWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(thaiAddressRepositoryProvider);

    // Get all villages (this loads ~70,000 villages)
    final allVillages = repository.villages;
    print('Total villages: ${allVillages.length}');

    // Search villages by name
    final searchResults = repository.searchVillages('บ้าน', maxResults: 20);
    print('Search results for "บ้าน": ${searchResults.length} found');

    // Get villages in a specific sub-district
    final subDistrictId = 1;
    final villagesInSubDistrict = repository.getVillagesBySubDistrict(subDistrictId);
    print('Villages in sub-district $subDistrictId: ${villagesInSubDistrict.length}');

    // Build custom list of village results
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final villageResult = searchResults[index];
        final village = villageResult.village;
        final subDistrict = villageResult.subDistrict;
        final district = villageResult.district;
        final province = villageResult.province;

        return Card(
          child: ListTile(
            title: Text(village.nameTh),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('หมู่ที่ ${village.mooNo}'),
                Text('$subDistrictName $districtName $provinceName'),
              ],
            ),
            trailing: Text('ID: ${village.id}'),
          ),
        );
      },
    );
  }
}
```

**Repository Methods for Villages:**

```dart
// Get all villages
final allVillages = repository.villages;

// Search villages with substring matching
final results = repository.searchVillages('ชื่อหมู่บ้าน', maxResults: 20);

// Get villages by sub-district ID
final villagesBySubDistrict = repository.getVillagesBySubDistrict(subDistrictId);

// Get village by ID
final village = repository.getVillageById(villageId);
```

**VillageSuggestion Object Structure:**

```dart
class VillageSuggestion {
  final Village village;           // Village data with id, nameTh, mooNo
  final SubDistrict subDistrict;   // Parent sub-district
  final District district;         // Parent district
  final Province province;         // Parent province
  final String displayText;        // "หมู่บ้านชื่อ • หมู่ที่X"
  final String displayMoo;         // "หมู่ที่X"
}
```

#### 4. Village Search with Provider State

Create reactive village search with state management:

```dart
// Custom provider for village search results
final villageSearchProvider = StateNotifierProvider<VillageSearchNotifier, List<VillageSuggestion>>((ref) {
  final repository = ref.watch(thaiAddressRepositoryProvider);
  return VillageSearchNotifier(repository);
});

class VillageSearchNotifier extends StateNotifier<List<VillageSuggestion>> {
  final ThaiAddressRepository repository;

  VillageSearchNotifier(this.repository) : super([]);

  void search(String query, {int maxResults = 20}) {
    if (query.isEmpty) {
      state = [];
      return;
    }

    final results = repository.searchVillages(query, maxResults: maxResults);
    state = results;
  }

  void clear() {
    state = [];
  }
}

// Use in widget
class VillageSearchReactiveWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<VillageSearchReactiveWidget> createState() => _VillageSearchReactiveWidgetState();
}

class _VillageSearchReactiveWidgetState extends ConsumerState<VillageSearchReactiveWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(villageSearchProvider);
    final searchNotifier = ref.read(villageSearchProvider.notifier);
    final addressNotifier = ref.read(thaiAddressNotifierProvider.notifier);

    return Column(
      children: [
        // Search input
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'ค้นหาหมู่บ้าน',
            hintText: 'พิมพ์ชื่อหมู่บ้าน',
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.location_on_outlined),
          ),
          onChanged: (query) {
            searchNotifier.search(query, maxResults: 15);
          },
        ),

        const SizedBox(height: 16),

        // Results count
        if (searchResults.isNotEmpty)
          Text('พบ ${searchResults.length} หมู่บ้าน',
              style: Theme.of(context).textTheme.bodySmall),

        const SizedBox(height: 8),

        // Results list
        Expanded(
          child: searchResults.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'เริ่มพิมพ์เพื่อค้นหา'
                        : 'ไม่พบหมู่บ้าน',
                  ),
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final result = searchResults[index];
                    final village = result.village;

                    return ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(village.nameTh),
                      subtitle: Text(
                        '${result.displayMoo} • ${result.subDistrict.nameTh}',
                      ),
                      trailing: Text(
                        result.district.nameTh,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        // Auto-fill address fields
                        addressNotifier.selectSubDistrict(result.subDistrict);
                        _searchController.clear();
                        searchNotifier.clear();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

#### 4. Get All Data Programmatically

Access complete data structures for custom implementation:

```dart
class DataAccessExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(thaiAddressRepositoryProvider);

    // Get all provinces
    final provinces = repository.provinces;
    print('Total provinces: ${provinces.length}');

    // Get all provinces with their districts count
    final provincesWithCounts = provinces.map((p) {
      final districts = repository.getDistrictsByProvince(p.id);
      return {
        'name': p.nameTh,
        'districtCount': districts.length,
      };
    }).toList();

    // Get specific data by ID
    final province = repository.getProvinceById(1);
    print('Province ID 1: ${province?.nameTh}');

    // Get by geography (region)
    final geographies = repository.geographies;
    for (var geo in geographies) {
      print('Region: ${geo.nameTh}');
      final provincesByGeo = repository.getProvincesByGeography(geo.id);
      print('Provinces in this region: ${provincesByGeo.length}');
    }

    // Search across data
    final searchResults = repository.searchProvinces('กรุง');
    print('Search results for "กรุง": ${searchResults.length} found');

    return Center(
      child: Text('Check console for data'),
    );
  }
}
```

#### 5. Multi-level Filtering Example

Build complex filtering logic:

```dart
class AdvancedFilterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(thaiAddressRepositoryProvider);
    final state = ref.watch(thaiAddressNotifierProvider);

    // Get all available zip codes for current selection
    final availableZipCodes = state.selectedSubDistrict != null
        ? repository.getZipCodesBySubDistrict(state.selectedSubDistrict!.id)
        : <String>[];

    // Get all sub-districts for a province (skip district selection)
    final allSubDistrictsInProvince = state.selectedProvince != null
        ? repository.getDistrictsByProvince(state.selectedProvince!.id)
            .expand((d) => repository.getSubDistrictsByDistrict(d.id))
            .toList()
        : <SubDistrict>[];

    // Get districts with the most sub-districts
    final districtsBySize = repository.provinces
        .expand((p) => repository.getDistrictsByProvince(p.id))
        .map((d) => {
          'district': d,
          'subDistrictCount': repository.getSubDistrictsByDistrict(d.id).length,
        })
        .toList()
        ..sort((a, b) => (b['subDistrictCount'] as int).compareTo(a['subDistrictCount'] as int));

    return SingleChildScrollView(
      child: Column(
        children: [
          // Show all sub-districts in selected province
          if (allSubDistrictsInProvince.isNotEmpty)
            Column(
              children: [
                const Text('ตำบลทั้งหมดในจังหวัดนี้:'),
                ...allSubDistrictsInProvince.map((s) => ListTile(
                  title: Text(s.nameTh),
                )),
              ],
            ),

          const SizedBox(height: 20),

          // Show available zip codes
          if (availableZipCodes.isNotEmpty)
            Column(
              children: [
                const Text('รหัสไปรษณีย์ที่มี:'),
                ...availableZipCodes.map((z) => Chip(label: Text(z))),
              ],
            ),

          const SizedBox(height: 20),

          // Show top 5 largest districts
          const Text('อำเภอที่มีตำบลมากที่สุด:'),
          ...districtsBySize.take(5).map((item) {
            final district = item['district'] as District;
            final count = item['subDistrictCount'] as int;
            return ListTile(
              title: Text(district.nameTh),
              trailing: Text('$count ตำบล'),
            );
          }),
        ],
      ),
    );
  }
}
```

#### 6. Form Integration with State Persistence

Combine data access with form state management:

```dart
class PersistentAddressForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<PersistentAddressForm> createState() => _PersistentAddressFormState();
}

class _PersistentAddressFormState extends ConsumerState<PersistentAddressForm> {
  late TextEditingController _provinceController;
  late TextEditingController _districtController;

  @override
  void initState() {
    super.initState();
    _provinceController = TextEditingController();
    _districtController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(thaiAddressRepositoryProvider);
    final state = ref.watch(thaiAddressNotifierProvider);
    final notifier = ref.read(thaiAddressNotifierProvider.notifier);

    // Update controllers when state changes
    _provinceController.text = state.selectedProvince?.nameTh ?? '';
    _districtController.text = state.selectedDistrict?.nameTh ?? '';

    return Column(
      children: [
        // Province input with autocomplete
        Autocomplete<Province>(
          optionsBuilder: (TextEditingValue value) {
            if (value.text.isEmpty) {
              return repository.provinces;
            }
            return repository.searchProvinces(value.text);
          },
          onSelected: (Province selection) {
            _provinceController.text = selection.nameTh;
            notifier.selectProvince(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            _provinceController = controller;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: 'จังหวัด'),
            );
          },
          displayStringForOption: (p) => p.nameTh,
        ),

        const SizedBox(height: 12),

        // District input with filtered options
        if (state.selectedProvince != null)
          Autocomplete<District>(
            optionsBuilder: (TextEditingValue value) {
              final districts = repository.getDistrictsByProvince(
                state.selectedProvince!.id,
              );
              if (value.text.isEmpty) {
                return districts;
              }
              return districts.where((d) =>
                  d.nameTh.toLowerCase().contains(value.text.toLowerCase())
              );
            },
            onSelected: (District selection) {
              _districtController.text = selection.nameTh;
              notifier.selectDistrict(selection);
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              _districtController = controller;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: 'อำเภอ'),
              );
            },
            displayStringForOption: (d) => d.nameTh,
          ),
      ],
    );
  }

  @override
  void dispose() {
    _provinceController.dispose();
    _districtController.dispose();
    super.dispose();
  }
}
```

#### Key Benefits:

- ✅ **Full Control**: Create any UI design you want
- ✅ **Direct Data Access**: Get data without widget overhead
- ✅ **Custom Logic**: Implement complex filtering and searching
- ✅ **Flexibility**: Mix and match UI frameworks
- ✅ **Performance**: Optimize queries for your specific use case
- ✅ **State Integration**: Leverage Riverpod for reactive updates

````

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
````

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

## ❓ FAQ - บ่อยเจอ

### Q0: ❤️ วิธีไหนดีที่สุดที่แนะนำ?

**Scenario 0 - Standalone Usage!** 🚀

**เพราะอะไร:**

- ✅ ไม่ต้อง ProviderScope
- ✅ ไม่ต้อง state management
- ✅ Performance สูงสุด (O(1) HashMap + Early exit)
- ✅ Algorithm ที่ดีที่สุด (Isolate + Singleton + Caching)
- ✅ ควบคุมได้ทุกอย่าง

**เมื่อไหร่ใช้ Scenario อื่น:**

- ใช้ widget ของเรา → Scenario 1
- มี Provider/GetX/BLoC อยู่แล้ว → Scenario 3
- ต้องการ custom UI → Scenario 0 หรือ 2

### Q1: ผม GetX ใช้อยู่แล้ว, ต้องเปลี่ยนเป็น Riverpod ไหม?

**ไม่เลย!** ใช้ได้ทั้งสองอย่าง:

```dart
void main() {
  runApp(
    ProviderScope(  // Riverpod (thai_address_picker)
      child: GetMaterialApp(  // GetX (app ของคุณ)
        home: const MyHome(),
      ),
    ),
  );
}
```

### Q2: ผม BLoC pattern, ต้องใช้ ProviderScope ไหม?

**ต้องใช้** ถ้าคุณใช้ widget ที่มี UI ของแพ็คเกจ:

```dart
void main() {
  runApp(
    ProviderScope(  // ต้องใช้
      child: BlocProvider(
        create: (context) => MyBloc(),
        child: const MyApp(),
      ),
    ),
  );
}
```

หรือไม่ต้องใช้ถ้าเลือก Scenario 2 (repository อย่างเดียว)

### Q3: ProviderScope wrap ผิดลำดับ จะเป็นไรไหม?

**อาจ error ได้:**

```dart
// ❌ ผิด - ProviderScope อยู่ข้างใน
GetMaterialApp(
  home: ProviderScope(
    child: const MyHome(),
  ),
),

// ✅ ถูก - ProviderScope อยู่ข้างนอก
ProviderScope(
  child: GetMaterialApp(
    home: const MyHome(),
  ),
),
```

### Q4: ใช้เฉพาะ repository โดยไม่ใช้ widget ได้ไหม?

**ได้เลย!** ดู Scenario 2

```dart
// ไม่ต้อง ProviderScope
final repository = ThaiAddressRepository();
await repository.initialize();
final provinces = repository.provinces;
```

### Q5: ดึง address ที่เลือกได้ยังไง?

**ใช้ Riverpod (ถ้าใช้ widget):**

```dart
final state = ref.watch(thaiAddressNotifierProvider);
print(state.toThaiAddress());
```

**ใช้ callback:**

```dart
ThaiAddressForm(
  onChanged: (address) {
    print(address.provinceTh);  // ได้เลย
  },
)
```

### Q6: Riverpod จำเป็นต้องใช้ ConsumerWidget ไหม?

**ไม่อย่างไร!** สามารถใช้ `ref` ด้วยหลาย วิธี:

```dart
// 1. ConsumerWidget (easy)
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(thaiAddressNotifierProvider);
    return Text('${state.selectedProvince?.nameTh}');
  }
}

// 2. Consumer (บ่อย)
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(thaiAddressNotifierProvider);
        return Text('${state.selectedProvince?.nameTh}');
      },
    );
  }
}

// 3. ConsumerStatefulWidget (มี state)
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(thaiAddressNotifierProvider);
    return Text('${state.selectedProvince?.nameTh}');
  }
}
```

### Q7: ใช้ widget หลายตัวในหน้าเดียว ได้ไหม?

**ได้เลย!** State ทั้งหมดส่วนกันด้วย:

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(thaiAddressNotifierProvider);

    return Column(
      children: [
        ThaiAddressForm(
          onChanged: (_) {},  // ส่วนแรก
        ),
        const SizedBox(height: 20),
        ZipCodeAutocomplete(  // ส่วนสอง
          onZipCodeSelected: (_) {},
        ),
        const SizedBox(height: 20),
        // แสดงผลที่เลือก - update แบบ real-time
        Text('จังหวัด: ${state.selectedProvince?.nameTh ?? "ยังไม่เลือก"}'),
      ],
    );
  }
}
```

### Q8: ต้อง initialize repository ไหม?

**ใช่!** ถ้าใช้ repository โดยตรง:

```dart
final repository = ThaiAddressRepository();
await repository.initialize();  // ต้องเรียก

// ถ้าใช้ widget - ทำให้โดยอัตโนมัติ
```

### Q9: ใช้ได้กับ Flutter Web ไหม?

**ได้!** รองรับ iOS, Android, Web, Desktop ทั้งหมด

### Q10: Error "ProviderScope not found" แสดงเมื่อไร?

**เมื่อ:**

- ใช้ widget (ThaiAddressForm, ZipCodeAutocomplete) แต่ไม่ wrap ด้วย ProviderScope
- ใช้ ref.watch() แต่ ProviderScope ไม่อยู่

**แก้:** ทำตาม Scenario 1

### Q11: 🆕 Standalone vs Repository Only (Scenario 2) ต่างกันยังไง?

**เหมือนกัน!** Scenario 0 (Standalone) = Scenario 2 (Repository Only)

แต่ Scenario 0 แสดง:

- ✅ Autocomplete algorithms (Zip Code + Village)
- ✅ Performance optimization techniques
- ✅ Complete working example

### Q12: 🆕 Algorithm อะไรที่ใช้ใน Standalone?

**Data Structure:**

- **HashMap Index**: O(1) lookup สำหรับ Province/District/SubDistrict
- **Zip Code Index**: O(1) lookup + prefix matching
- **Village List**: Linear search with early exit

**Search Algorithms:**

- **Zip Code Search**: Prefix matching + early exit หลัง maxResults
- **Village Search**: Substring matching + early exit
- **Complexity**: O(k) where k = maxResults (ไม่ใช่ O(n))

**Loading:**

- **Isolate-based**: JSON parsing ใน background thread
- **Singleton**: Load once, cache forever
- **Non-blocking**: UI ไม่ค้าง

### Q13: 🆕 Performance จริงๆ เป็นยังไง?

**Benchmark (iOS/Android/Web):**

- Province lookup: **< 1ms** (O(1))
- District lookup: **< 1ms** (O(1))
- Zip search (10 results): **< 5ms** (Early exit)
- Village search (15 results): **< 10ms** (Early exit)
- Initial load: **200-500ms** (Isolate, cached)

**Memory:**

- ~5-10MB (all data cached)
- Singleton = shared across app

### Q14: 🆕 Built-in Classes มีอะไรบ้าง?

**Data Classes:**

```dart
// Province, District, SubDistrict, Village
final province = repository.getProvinceById(1);

// Autocomplete suggestion classes
ZipCodeSuggestion {
  String zipCode;
  SubDistrict subDistrict;
  District? district;
  Province? province;
  String get displayText;  // "10110 • พระบรมมหาราชวัง • พระนคร • กรุงเทพมหานคร"
  String get displayTextEn;
}

VillageSuggestion {
  Village village;
  SubDistrict? subDistrict;
  District? district;
  Province? province;
  String get displayText;  // "บ้านสวนผัก • หมู่ 3 • ..."
  String get displayMoo;   // "หมู่ 3"
}
```

### Q15: 🆕 Autocomplete API มีอะไรบ้าง?

**Zip Code Autocomplete:**

```dart
// Prefix matching + early exit
List<ZipCodeSuggestion> searchZipCodes(
  String query,      // "101" → finds "10110", "10120", etc.
  {int maxResults = 20}  // Early exit หลัง 20 results
);
```

**Village Autocomplete:**

```dart
// Substring matching + early exit
List<VillageSuggestion> searchVillages(
  String query,      // "บ้าน" → substring match
  {int maxResults = 20}  // Early exit
);
```

**Other Methods:**

```dart
// O(1) lookups
Province? getProvinceById(int id);
District? getDistrictById(int id);
SubDistrict? getSubDistrictById(int id);
Village? getVillageById(int id);

// O(1) filtering
List<District> getDistrictsByProvince(int provinceId);
List<SubDistrict> getSubDistrictsByDistrict(int districtId);
List<Village> getVillagesBySubDistrict(int subDistrictId);
List<SubDistrict> getSubDistrictsByZipCode(String zipCode);

// Search (Early exit)
List<Province> searchProvinces(String query);
List<District> searchDistricts(String query);
```

---

## Example Files

All examples are available in the [`example/lib/`](example/lib/) directory:

### Basic Usage

- [`main.dart`](example/lib/main.dart) - Basic usage with ThaiAddressForm
- [`complete_integration_example.dart`](example/lib/complete_integration_example.dart) - Complete integration example
- [`standalone_usage_example.dart`](example/lib/standalone_usage_example.dart) - Standalone usage without Riverpod

### Widget Examples

- [`custom_ui_example.dart`](example/lib/custom_ui_example.dart) - Custom UI styling
- [`repository_only_example.dart`](example/lib/repository_only_example.dart) - Repository-only usage

### State Management Integration

- [`provider_integration_example.dart`](example/lib/provider_integration_example.dart) - Provider integration
- [`getx_integration_example.dart`](example/lib/getx_integration_example.dart) - GetX integration

### Zip Code Features

- [`zip_code_autocomplete_example.dart`](example/lib/zip_code_autocomplete_example.dart) - Zip code autocomplete with suggestions
- [`zip_code_lookup_example.dart`](example/lib/zip_code_lookup_example.dart) - Reverse lookup by zip code
- **[`disable_zipcode_autocomplete_example.dart`](example/lib/disable_zipcode_autocomplete_example.dart)** - ✨ Disable autocomplete for simpler UI
- **[`compare_zipcode_modes_example.dart`](example/lib/compare_zipcode_modes_example.dart)** - ✨ Compare autocomplete vs simple TextField

### Village Features

- [`village_autocomplete_example.dart`](example/lib/village_autocomplete_example.dart) - Village autocomplete with Moo number

To run examples:

```bash
cd example
flutter run
```

---

## Requirements

- Flutter SDK: >=1.17.0
- Dart SDK: ^3.9.2

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you find this package helpful, please give it a ⭐ on GitHub!
