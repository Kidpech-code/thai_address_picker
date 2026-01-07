import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/geography.dart';
import '../models/province.dart';
import '../models/district.dart';
import '../models/sub_district.dart';

/// Helper class for isolate-based JSON parsing
class _JsonParseParams {
  final String jsonString;
  final String type;

  _JsonParseParams(this.jsonString, this.type);
}

/// Top-level function for isolate to parse JSON
List<dynamic> _parseJsonInIsolate(_JsonParseParams params) {
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

  // Indexed data for fast lookup
  Map<int, Geography>? _geographyMap;
  Map<int, Province>? _provinceMap;
  Map<int, District>? _districtMap;
  Map<int, SubDistrict>? _subDistrictMap;
  Map<String, List<SubDistrict>>? _zipCodeIndex;

  bool _isInitialized = false;

  /// Initialize the repository by loading and parsing all JSON files
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load all JSON files in parallel
      final results = await Future.wait([
        rootBundle.loadString('$_basePath/geographies.json'),
        rootBundle.loadString('$_basePath/provinces.json'),
        rootBundle.loadString('$_basePath/districts.json'),
        rootBundle.loadString('$_basePath/sub_districts.json'),
      ]);

      // Parse JSON in isolates to avoid blocking UI thread
      final parsedResults = await Future.wait([
        compute(_parseJsonInIsolate, _JsonParseParams(results[0], 'geography')),
        compute(_parseJsonInIsolate, _JsonParseParams(results[1], 'province')),
        compute(_parseJsonInIsolate, _JsonParseParams(results[2], 'district')),
        compute(
          _parseJsonInIsolate,
          _JsonParseParams(results[3], 'subDistrict'),
        ),
      ]);

      // Cast and store results
      _geographies = parsedResults[0].cast<Geography>();
      _provinces = parsedResults[1].cast<Province>();
      _districts = parsedResults[2].cast<District>();
      _subDistricts = parsedResults[3].cast<SubDistrict>();

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
