import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/geography.dart';
import '../models/province.dart';
import '../models/district.dart';
import '../models/sub_district.dart';
import '../models/village.dart';

/// Helper class for isolate-based JSON parsing
@visibleForTesting
class JsonParseParams {
  final String jsonString;
  final String type;

  JsonParseParams(this.jsonString, this.type);
}

/// Top-level function for isolate to parse JSON
@visibleForTesting
List<dynamic> parseJsonInIsolate(JsonParseParams params) {
  final List<dynamic> jsonList = jsonDecode(params.jsonString) as List;

  switch (params.type) {
    case 'geography':
      return jsonList.map((json) => Geography.fromJson(json)).toList();
    case 'province':
      return jsonList.map((json) => Province.fromJson(json)).toList();
    case 'district':
      return jsonList.map((json) => District.fromJson(json)).toList();
    case 'subDistrict':
      return jsonList.map((json) => SubDistrict.fromJson(json)).toList();
    case 'village':
      return jsonList.map((json) => Village.fromJson(json)).toList();
    default:
      throw Exception('Unknown type: ${params.type}');
  }
}

/// Repository for Thai address data with high-performance caching and isolate-based parsing
///
/// This singleton repository provides:
/// - Lazy initialization with isolate-based JSON parsing for non-blocking UI
/// - In-memory caching with O(1) lookup via HashMap indexes
/// - Efficient search with early exit optimization
/// - Thread-safe singleton pattern
///
/// Usage:
/// ```dart
/// final repository = ThaiAddressRepository();
/// await repository.initialize();
/// final provinces = repository.provinces;
/// ```
class ThaiAddressRepository {
  // Singleton instance
  static final ThaiAddressRepository _instance =
      ThaiAddressRepository._internal();
  factory ThaiAddressRepository() => _instance;
  ThaiAddressRepository._internal();

  // Asset paths with package prefix for library usage
  static const String _packageName = 'thai_address_picker';
  static const String _basePath = 'packages/$_packageName/assets/data/raw';

  // Cached data
  List<Geography>? _geographies;
  List<Province>? _provinces;
  List<District>? _districts;
  List<SubDistrict>? _subDistricts;
  List<Village>? _villages;

  // Indexed data for fast lookup
  Map<int, Geography>? _geographyMap;
  Map<int, Province>? _provinceMap;
  Map<int, District>? _districtMap;
  Map<int, SubDistrict>? _subDistrictMap;
  Map<int, List<Village>>? _subDistrictVillageMap;
  Map<String, List<SubDistrict>>? _zipCodeIndex;

  bool _isInitialized = false;

  /// Resets the repository state for testing purposes only
  @visibleForTesting
  void resetForTesting() {
    _isInitialized = false;
    _geographies = null;
    _provinces = null;
    _districts = null;
    _subDistricts = null;
    _villages = null;
    _geographyMap = null;
    _provinceMap = null;
    _districtMap = null;
    _subDistrictMap = null;
    _subDistrictVillageMap = null;
    _zipCodeIndex = null;
  }

  /// Initialize the repository by loading and parsing all JSON files
  Future<void> initialize({AssetBundle? bundle, bool useIsolate = true}) async {
    if (_isInitialized) return;

    final targetBundle = bundle ?? rootBundle;

    try {
      // Load all JSON files in parallel
      final results = await Future.wait([
        targetBundle.loadString('$_basePath/geographies.json'),
        targetBundle.loadString('$_basePath/provinces.json'),
        targetBundle.loadString('$_basePath/districts.json'),
        targetBundle.loadString('$_basePath/sub_districts.json'),
        targetBundle.loadString('$_basePath/villages.json'),
      ]);

      // Helper to parse or compute
      Future<List<dynamic>> parse(String json, String type) {
        final params = JsonParseParams(json, type);
        return useIsolate
            ? compute(parseJsonInIsolate, params)
            : Future.value(parseJsonInIsolate(params));
      }

      // Parse JSON
      final parsedResults = await Future.wait([
        parse(results[0], 'geography'),
        parse(results[1], 'province'),
        parse(results[2], 'district'),
        parse(results[3], 'subDistrict'),
        parse(results[4], 'village'),
      ]);

      // Cast and store results
      _geographies = parsedResults[0].cast<Geography>();
      _provinces = parsedResults[1].cast<Province>();
      _districts = parsedResults[2].cast<District>();
      _subDistricts = parsedResults[3].cast<SubDistrict>();
      _villages = parsedResults[4].cast<Village>();

      // Build indexes for fast lookup
      _buildIndexes();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize ThaiAddressRepository: $e');
    }
  }

  /// Build in-memory indexes for fast lookups
  void _buildIndexes() {
    _geographyMap = {for (var g in _geographies!) g.id: g};
    _provinceMap = {for (var p in _provinces!) p.id: p};
    _districtMap = {for (var d in _districts!) d.id: d};
    _subDistrictMap = {for (var s in _subDistricts!) s.id: s};

    // Build sub-district to village index
    _subDistrictVillageMap = {};
    for (var village in _villages!) {
      _subDistrictVillageMap!
          .putIfAbsent(village.subDistrictId, () => [])
          .add(village);
    }

    // Sort villages by moo_no
    for (var list in _subDistrictVillageMap!.values) {
      list.sort((a, b) => a.mooNo.compareTo(b.mooNo));
    }

    // Build zip code index (one zip code can have multiple subdistricts)
    _zipCodeIndex = {};
    for (var subDistrict in _subDistricts!) {
      _zipCodeIndex!
          .putIfAbsent(subDistrict.zipCode, () => [])
          .add(subDistrict);
    }
  }

  /// Ensure repository is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'ThaiAddressRepository is not initialized. Call initialize() first.',
      );
    }
  }

  // Getters
  List<Geography> get geographies {
    _ensureInitialized();
    return _geographies!;
  }

  List<Province> get provinces {
    _ensureInitialized();
    return _provinces!;
  }

  List<District> get districts {
    _ensureInitialized();
    return _districts!;
  }

  List<SubDistrict> get subDistricts {
    _ensureInitialized();
    return _subDistricts!;
  }

  List<Village> get villages {
    _ensureInitialized();
    return _villages!;
  }

  // Lookup by ID
  Geography? getGeographyById(int id) => _geographyMap?[id];
  Province? getProvinceById(int id) => _provinceMap?[id];
  District? getDistrictById(int id) => _districtMap?[id];
  SubDistrict? getSubDistrictById(int id) => _subDistrictMap?[id];

  // Filter methods for cascading selection
  List<Province> getProvincesByGeography(int geographyId) {
    _ensureInitialized();
    return _provinces!.where((p) => p.geographyId == geographyId).toList();
  }

  List<District> getDistrictsByProvince(int provinceId) {
    _ensureInitialized();
    return _districts!.where((d) => d.provinceId == provinceId).toList();
  }

  List<SubDistrict> getSubDistrictsByDistrict(int districtId) {
    _ensureInitialized();
    return _subDistricts!.where((s) => s.districtId == districtId).toList();
  }

  List<Village> getVillagesBySubDistrict(int subDistrictId) {
    _ensureInitialized();
    return _subDistrictVillageMap?[subDistrictId] ?? [];
  }

  // Reverse lookup by zip code
  List<SubDistrict> getSubDistrictsByZipCode(String zipCode) {
    _ensureInitialized();
    return _zipCodeIndex?[zipCode] ?? [];
  }

  // Search methods with debounce-friendly design
  List<Province> searchProvinces(String query) {
    _ensureInitialized();
    if (query.isEmpty) return _provinces!;

    final lowerQuery = query.toLowerCase();
    return _provinces!
        .where(
          (p) =>
              p.nameTh.toLowerCase().contains(lowerQuery) ||
              p.nameEn.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  List<District> searchDistricts(String query, {int? provinceId}) {
    _ensureInitialized();
    var results = provinceId != null
        ? getDistrictsByProvince(provinceId)
        : _districts!;

    if (query.isEmpty) return results;

    final lowerQuery = query.toLowerCase();
    return results
        .where(
          (d) =>
              d.nameTh.toLowerCase().contains(lowerQuery) ||
              d.nameEn.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  List<SubDistrict> searchSubDistricts(String query, {int? districtId}) {
    _ensureInitialized();
    var results = districtId != null
        ? getSubDistrictsByDistrict(districtId)
        : _subDistricts!;

    if (query.isEmpty) return results;

    final lowerQuery = query.toLowerCase();
    return results
        .where(
          (s) =>
              s.nameTh.toLowerCase().contains(lowerQuery) ||
              s.nameEn.toLowerCase().contains(lowerQuery) ||
              s.zipCode.contains(query),
        )
        .toList();
  }

  /// Search villages with auto-suggestion data
  ///
  /// Returns list of [VillageSuggestion] with full address hierarchy.
  ///
  /// Algorithm: O(k) where k = min(matches, maxResults)
  /// - Uses substring matching for flexible search
  /// - Early exit when reaching [maxResults] for performance
  /// - HashMap-based deduplication for unique entries
  /// - Results sorted alphabetically for consistent UI
  ///
  /// Parameters:
  /// - [query]: Village name search (Thai text)
  /// - [maxResults]: Maximum suggestions to return (default: 20)
  ///
  /// Returns: Sorted list of [VillageSuggestion] matching the query
  ///
  /// Example:
  /// ```dart
  /// final suggestions = repository.searchVillages('บ้าน', maxResults: 10);
  /// // Returns: [บ้านทุ่ง, บ้านนา, บ้านสวน, ...]
  /// ```
  List<VillageSuggestion> searchVillages(String query, {int maxResults = 20}) {
    _ensureInitialized();

    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final suggestions = <String, VillageSuggestion>{};

    for (var village in _villages!) {
      // Stop if we have enough results (performance optimization)
      if (suggestions.length >= maxResults) break;

      // Check if village name contains query (substring match)
      if (village.nameTh.toLowerCase().contains(lowerQuery)) {
        final key = '${village.id}';

        // Skip if we already have this exact village
        if (suggestions.containsKey(key)) continue;

        final subDistrict = getSubDistrictById(village.subDistrictId);
        final district = subDistrict != null
            ? getDistrictById(subDistrict.districtId)
            : null;
        final province = district != null
            ? getProvinceById(district.provinceId)
            : null;

        suggestions[key] = VillageSuggestion(
          village: village,
          subDistrict: subDistrict,
          district: district,
          province: province,
        );
      }
    }

    // Sort by village name for consistent ordering
    final sortedList = suggestions.values.toList()
      ..sort((a, b) => a.village.nameTh.compareTo(b.village.nameTh));

    return sortedList;
  }

  /// Search zip codes with auto-suggestion data
  ///
  /// Returns list of [ZipCodeSuggestion] with full address hierarchy.
  ///
  /// Algorithm: O(k) where k = min(matches, maxResults)
  /// - Uses prefix matching for accurate suggestions
  /// - Early exit when reaching [maxResults] for performance
  /// - HashMap-based deduplication for unique entries
  /// - Results sorted by zip code for consistent UI
  ///
  /// Parameters:
  /// - [query]: Partial or complete zip code (1-5 digits)
  /// - [maxResults]: Maximum suggestions to return (default: 20)
  ///
  /// Returns: Sorted list of [ZipCodeSuggestion] matching the query
  ///
  /// Example:
  /// ```dart
  /// final suggestions = repository.searchZipCodes('102', maxResults: 10);
  /// // Returns: [10200, 10210, 10220, ...]
  /// ```
  List<ZipCodeSuggestion> searchZipCodes(String query, {int maxResults = 20}) {
    _ensureInitialized();

    if (query.isEmpty) return [];

    // Use prefix matching for better UX
    // Only show results that start with the query for cleaner suggestions
    final suggestions = <String, ZipCodeSuggestion>{};

    for (var subDistrict in _subDistricts!) {
      // Stop if we have enough results (performance optimization)
      if (suggestions.length >= maxResults) break;

      // Check if zip code starts with query (prefix match)
      if (subDistrict.zipCode.startsWith(query)) {
        final key = '${subDistrict.zipCode}_${subDistrict.id}';

        // Skip if we already have this exact combination
        if (suggestions.containsKey(key)) continue;

        final district = getDistrictById(subDistrict.districtId);
        final province = district != null
            ? getProvinceById(district.provinceId)
            : null;

        suggestions[key] = ZipCodeSuggestion(
          zipCode: subDistrict.zipCode,
          subDistrict: subDistrict,
          district: district,
          province: province,
        );
      }
    }

    // Sort by zip code for consistent ordering
    final sortedList = suggestions.values.toList()
      ..sort((a, b) => a.zipCode.compareTo(b.zipCode));

    return sortedList;
  }

  /// Get all zip codes (for autocomplete list)
  /// Returns unique zip codes sorted
  List<String> getAllZipCodes() {
    _ensureInitialized();
    final uniqueZips = <String>{};
    for (var subDistrict in _subDistricts!) {
      uniqueZips.add(subDistrict.zipCode);
    }
    return uniqueZips.toList()..sort();
  }

  /// Get district and province info from subdistrict
  Map<String, dynamic> getFullAddressFromSubDistrict(SubDistrict subDistrict) {
    final district = getDistrictById(subDistrict.districtId);
    final province = district != null
        ? getProvinceById(district.provinceId)
        : null;

    return {
      'subDistrict': subDistrict,
      'district': district,
      'province': province,
    };
  }
}

/// Zip code suggestion data class for autocomplete
///
/// Encapsulates all address information for a single zip code suggestion:
/// - [zipCode]: The 5-digit postal code
/// - [subDistrict]: Associated sub-district data
/// - [district]: Parent district (nullable)
/// - [province]: Parent province (nullable)
///
/// Provides formatted display strings for UI:
/// - [displayText]: Thai format (zipCode • subDistrict • district • province)
/// - [displayTextEn]: English format (optional secondary text)
///
/// Used by [ZipCodeAutocomplete] widget for dropdown suggestions.
class ZipCodeSuggestion {
  final String zipCode;
  final SubDistrict subDistrict;
  final District? district;
  final Province? province;

  ZipCodeSuggestion({
    required this.zipCode,
    required this.subDistrict,
    this.district,
    this.province,
  });

  /// Display text for suggestion dropdown
  String get displayText {
    final parts = <String>[zipCode];
    if (subDistrict.nameTh.isNotEmpty) parts.add(subDistrict.nameTh);
    if (district?.nameTh != null) parts.add(district!.nameTh);
    if (province?.nameTh != null) parts.add(province!.nameTh);
    return parts.join(' • ');
  }

  /// Secondary display text (English)
  String get displayTextEn {
    final parts = <String>[];
    if (subDistrict.nameEn.isNotEmpty) parts.add(subDistrict.nameEn);
    if (district?.nameEn != null) parts.add(district!.nameEn);
    if (province?.nameEn != null) parts.add(province!.nameEn);
    return parts.isEmpty ? '' : parts.join(' • ');
  }
}

/// Village suggestion data class for autocomplete
///
/// Encapsulates all address information for a single village suggestion:
/// - [village]: The village data with name and หมู่ (moo) number
/// - [subDistrict]: Parent sub-district (nullable)
/// - [district]: Parent district (nullable)
/// - [province]: Parent province (nullable)
///
/// Provides formatted display strings for UI:
/// - [displayText]: Thai format (village • subDistrict • district • province)
/// - [displayMoo]: หมู่ที่ (moo number) for display
///
/// Used by [VillageAutocomplete] widget for dropdown suggestions.
class VillageSuggestion {
  final Village village;
  final SubDistrict? subDistrict;
  final District? district;
  final Province? province;

  VillageSuggestion({
    required this.village,
    this.subDistrict,
    this.district,
    this.province,
  });

  /// Display text for suggestion dropdown
  String get displayText {
    final parts = <String>[village.nameTh];
    if (village.mooNo > 0) parts.add('หมู่ ${village.mooNo}');
    if (subDistrict?.nameTh != null) parts.add(subDistrict!.nameTh);
    if (district?.nameTh != null) parts.add(district!.nameTh);
    if (province?.nameTh != null) parts.add(province!.nameTh);
    return parts.join(' • ');
  }

  /// Moo number display
  String get displayMoo {
    return village.mooNo > 0 ? 'หมู่ ${village.mooNo}' : '';
  }
}
