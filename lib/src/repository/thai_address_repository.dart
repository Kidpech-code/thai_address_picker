import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../contracts/i_thai_address_repository.dart';
import '../models/geography.dart';
import '../models/province.dart';
import '../models/district.dart';
import '../models/sub_district.dart';
import '../models/village.dart';
import '../models/suggestions.dart';

// Re-export so existing `import '.../thai_address_repository.dart'` paths
// continue to resolve ZipCodeSuggestion and VillageSuggestion.
export '../models/suggestions.dart' show ZipCodeSuggestion, VillageSuggestion;

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

/// Default [IThaiAddressRepository] implementation backed by the package's
/// bundled JSON asset files.
///
/// ### Memory strategy — no OOM from villages
/// Only the four **core** datasets (geographies, provinces, districts,
/// sub-districts) are loaded during [initialize].  The **villages** dataset
/// (~75 000 entries) is loaded **lazily** on first access, indexed by
/// `subDistrictId`, and sorted by `mooNo`.  Call [clearVillageCache] to evict
/// that index and reclaim memory when (e.g.) the user navigates away from a
/// village-selection screen.
///
/// ### Concurrency
/// All `??=` guards are safe under Dart's single-threaded event loop.  Heavy
/// JSON decoding is offloaded to a background isolate via `compute`.
///
/// ### Singleton
/// The singleton pattern ensures indexes are built only once per process.
///
/// ```dart
/// final repo = ThaiAddressRepository();
/// await repo.initialize();
/// ```
class ThaiAddressRepository implements IThaiAddressRepository {
  // Singleton instance
  static final ThaiAddressRepository _instance =
      ThaiAddressRepository._internal();
  factory ThaiAddressRepository() => _instance;
  ThaiAddressRepository._internal();

  // Asset paths with package prefix for library usage
  static const String _packageName = 'thai_address_picker';
  static const String _basePath = 'packages/$_packageName/assets/data/raw';

  // ── Core data (loaded at initialize) ─────────────────────────────────
  List<Geography>? _geographies;
  List<Province>? _provinces;
  List<District>? _districts;
  List<SubDistrict>? _subDistricts;

  // ── Core indexes ─────────────────────────────────────────────────────
  Map<int, Geography>? _geographyMap;
  Map<int, Province>? _provinceMap;
  Map<int, District>? _districtMap;
  Map<int, SubDistrict>? _subDistrictMap;
  Map<String, List<SubDistrict>>? _zipCodeIndex;

  // ── Village data — LAZY (NOT loaded at initialize) ───────────────────
  /// Coalesces concurrent callers so the file is decoded only once.
  Future<void>? _villageFuture;
  Map<int, List<Village>>? _subDistrictVillageMap;

  // ── Lifecycle ─────────────────────────────────────────────────────────
  bool _isInitialized = false;

  /// Stored during [initialize] so the lazy village loader can reuse it.
  AssetBundle? _bundle;
  bool _useIsolate = true;

  // ── IThaiAddressRepository: isInitialized ────────────────────────────
  @override
  bool get isInitialized => _isInitialized;

  // ── Test helper ───────────────────────────────────────────────────────

  /// Resets ALL internal state. Use only in tests — never in production.
  @visibleForTesting
  void resetForTesting() {
    _isInitialized = false;
    _geographies = null;
    _provinces = null;
    _districts = null;
    _subDistricts = null;
    _geographyMap = null;
    _provinceMap = null;
    _districtMap = null;
    _subDistrictMap = null;
    _zipCodeIndex = null;
    _subDistrictVillageMap = null;
    _villageFuture = null;
    _bundle = null;
  }

  // ── IThaiAddressRepository: initialize ───────────────────────────────

  @override
  Future<void> initialize({AssetBundle? bundle, bool useIsolate = true}) async {
    if (_isInitialized) return;

    _bundle = bundle;
    _useIsolate = useIsolate;
    final targetBundle = bundle ?? rootBundle;

    try {
      // Load the FOUR core files in parallel.
      // villages.json is intentionally excluded — loaded lazily on demand.
      final rawStrings = await Future.wait([
        targetBundle.loadString('$_basePath/geographies.json'),
        targetBundle.loadString('$_basePath/provinces.json'),
        targetBundle.loadString('$_basePath/districts.json'),
        targetBundle.loadString('$_basePath/sub_districts.json'),
      ]);

      Future<List<dynamic>> parse(String json, String type) {
        final params = JsonParseParams(json, type);
        return useIsolate
            ? compute(parseJsonInIsolate, params)
            : Future.value(parseJsonInIsolate(params));
      }

      final parsed = await Future.wait([
        parse(rawStrings[0], 'geography'),
        parse(rawStrings[1], 'province'),
        parse(rawStrings[2], 'district'),
        parse(rawStrings[3], 'subDistrict'),
      ]);

      _geographies = parsed[0].cast<Geography>();
      _provinces = parsed[1].cast<Province>();
      _districts = parsed[2].cast<District>();
      _subDistricts = parsed[3].cast<SubDistrict>();

      _buildCoreIndexes();
      _isInitialized = true;
    } catch (e, st) {
      throw Exception('ThaiAddressRepository.initialize failed: $e\n$st');
    }
  }

  // ── Core index builder (no villages) ─────────────────────────────────

  void _buildCoreIndexes() {
    _geographyMap = {for (final g in _geographies!) g.id: g};
    _provinceMap = {for (final p in _provinces!) p.id: p};
    _districtMap = {for (final d in _districts!) d.id: d};
    _subDistrictMap = {for (final s in _subDistricts!) s.id: s};

    _zipCodeIndex = {};
    for (final s in _subDistricts!) {
      _zipCodeIndex!.putIfAbsent(s.zipCode, () => []).add(s);
    }
    // NOTE: village index is built lazily — see _loadVillages().
  }

  // ── Lazy village loading ──────────────────────────────────────────────

  Future<void> _ensureVillagesLoaded() async {
    if (_subDistrictVillageMap != null) return;
    _villageFuture ??= _loadVillages();
    await _villageFuture;
  }

  Future<void> _loadVillages() async {
    _ensureInitialized();
    final targetBundle = _bundle ?? rootBundle;
    final jsonStr = await targetBundle.loadString('$_basePath/villages.json');
    final params = JsonParseParams(jsonStr, 'village');
    final parsed = _useIsolate
        ? await compute(parseJsonInIsolate, params)
        : parseJsonInIsolate(params);

    final villages = parsed.cast<Village>();
    final index = <int, List<Village>>{};
    for (final v in villages) {
      index.putIfAbsent(v.subDistrictId, () => []).add(v);
    }
    for (final list in index.values) {
      list.sort((a, b) => a.mooNo.compareTo(b.mooNo));
    }
    _subDistrictVillageMap = index;
  }

  // ── IThaiAddressRepository: clearVillageCache ─────────────────────────

  @override
  void clearVillageCache() {
    _subDistrictVillageMap = null;
    _villageFuture = null;
  }

  // ── Guard ─────────────────────────────────────────────────────────────

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'ThaiAddressRepository not initialized. Call initialize() first.',
      );
    }
  }

  // ── IThaiAddressRepository: bulk accessors ────────────────────────────

  @override
  List<Geography> get geographies {
    _ensureInitialized();
    return _geographies!;
  }

  @override
  List<Province> get provinces {
    _ensureInitialized();
    return _provinces!;
  }

  @override
  List<District> get districts {
    _ensureInitialized();
    return _districts!;
  }

  @override
  List<SubDistrict> get subDistricts {
    _ensureInitialized();
    return _subDistricts!;
  }

  // ── IThaiAddressRepository: point lookups ─────────────────────────────

  @override
  Geography? getGeographyById(int id) => _geographyMap?[id];
  @override
  Province? getProvinceById(int id) => _provinceMap?[id];
  @override
  District? getDistrictById(int id) => _districtMap?[id];
  @override
  SubDistrict? getSubDistrictById(int id) => _subDistrictMap?[id];

  // ── IThaiAddressRepository: cascading filters ────────────────────────

  @override
  List<Province> getProvincesByGeography(int geographyId) {
    _ensureInitialized();
    return _provinces!.where((p) => p.geographyId == geographyId).toList();
  }

  @override
  List<District> getDistrictsByProvince(int provinceId) {
    _ensureInitialized();
    return _districts!.where((d) => d.provinceId == provinceId).toList();
  }

  @override
  List<SubDistrict> getSubDistrictsByDistrict(int districtId) {
    _ensureInitialized();
    return _subDistricts!.where((s) => s.districtId == districtId).toList();
  }

  /// Lazy — triggers village loading on first call, O(1) thereafter.
  @override
  Future<List<Village>> getVillagesBySubDistrict(int subDistrictId) async {
    await _ensureVillagesLoaded();
    return _subDistrictVillageMap?[subDistrictId] ?? const [];
  }

  // ── IThaiAddressRepository: zip-code ──────────────────────────────────

  @override
  List<SubDistrict> getSubDistrictsByZipCode(String zipCode) {
    _ensureInitialized();
    return _zipCodeIndex?[zipCode] ?? const [];
  }

  // ── IThaiAddressRepository: search ───────────────────────────────────

  @override
  List<Province> searchProvinces(String query) {
    _ensureInitialized();
    if (query.isEmpty) return _provinces!;
    final q = query.toLowerCase();
    return _provinces!
        .where(
          (p) =>
              p.nameTh.toLowerCase().contains(q) ||
              p.nameEn.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  List<District> searchDistricts(String query, {int? provinceId}) {
    _ensureInitialized();
    final base = provinceId != null
        ? getDistrictsByProvince(provinceId)
        : _districts!;
    if (query.isEmpty) return base;
    final q = query.toLowerCase();
    return base
        .where(
          (d) =>
              d.nameTh.toLowerCase().contains(q) ||
              d.nameEn.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  List<SubDistrict> searchSubDistricts(String query, {int? districtId}) {
    _ensureInitialized();
    final base = districtId != null
        ? getSubDistrictsByDistrict(districtId)
        : _subDistricts!;
    if (query.isEmpty) return base;
    final q = query.toLowerCase();
    return base
        .where(
          (s) =>
              s.nameTh.toLowerCase().contains(q) ||
              s.nameEn.toLowerCase().contains(q) ||
              s.zipCode.contains(query),
        )
        .toList();
  }

  /// Lazy — triggers village loading on first call.
  ///
  /// Algorithm: O(k) with early-exit where k ≤ [maxResults].
  @override
  Future<List<VillageSuggestion>> searchVillages(
    String query, {
    int maxResults = 20,
  }) async {
    await _ensureVillagesLoaded();
    if (query.isEmpty) return const [];

    final q = query.toLowerCase();
    final results = <String, VillageSuggestion>{};

    for (final entry in _subDistrictVillageMap!.entries) {
      if (results.length >= maxResults) break;
      for (final village in entry.value) {
        if (results.length >= maxResults) break;
        if (!village.nameTh.toLowerCase().contains(q)) continue;

        final key = '${village.id}';
        if (results.containsKey(key)) continue;

        final subDistrict = getSubDistrictById(village.subDistrictId);
        final district = subDistrict != null
            ? getDistrictById(subDistrict.districtId)
            : null;
        final province = district != null
            ? getProvinceById(district.provinceId)
            : null;

        results[key] = VillageSuggestion(
          village: village,
          subDistrict: subDistrict,
          district: district,
          province: province,
        );
      }
    }

    return results.values.toList()
      ..sort((a, b) => a.village.nameTh.compareTo(b.village.nameTh));
  }

  @override
  List<ZipCodeSuggestion> searchZipCodes(String query, {int maxResults = 20}) {
    _ensureInitialized();
    if (query.isEmpty) return const [];

    final results = <String, ZipCodeSuggestion>{};
    for (final s in _subDistricts!) {
      if (results.length >= maxResults) break;
      if (!s.zipCode.startsWith(query)) continue;

      final key = '${s.zipCode}_${s.id}';
      if (results.containsKey(key)) continue;

      final district = getDistrictById(s.districtId);
      final province = district != null
          ? getProvinceById(district.provinceId)
          : null;

      results[key] = ZipCodeSuggestion(
        zipCode: s.zipCode,
        subDistrict: s,
        district: district,
        province: province,
      );
    }

    return results.values.toList()
      ..sort((a, b) => a.zipCode.compareTo(b.zipCode));
  }

  @override
  List<String> getAllZipCodes() {
    _ensureInitialized();
    return _zipCodeIndex!.keys.toList()..sort();
  }

  @override
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
