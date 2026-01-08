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

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  thai_address_picker: ^0.3.0
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

## Requirements

- Flutter SDK: >=1.17.0
- Dart SDK: ^3.9.2

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you find this package helpful, please give it a ⭐ on GitHub!
