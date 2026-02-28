import 'package:flutter/services.dart';

import '../models/geography.dart';
import '../models/province.dart';
import '../models/district.dart';
import '../models/sub_district.dart';
import '../models/village.dart';
import '../models/suggestions.dart';

/// Contract for the Thai address data layer.
///
/// Implementing this interface allows the data source to be swapped without
/// touching the UI or business-logic layers, e.g.
/// - **Asset JSON** (default implementation: `ThaiAddressRepository`)
/// - **SQLite** via `sqflite` for zero-startup-memory overhead
/// - **Remote REST API** for centralised address management
/// - **In-memory mock** for unit / widget tests
///
/// ```dart
/// // Mock for tests
/// class MockThaiAddressRepository implements IThaiAddressRepository {
///   @override bool get isInitialized => true;
///   @override Future<void> initialize({...}) async {}
///   // ... stub the methods you need
/// }
/// ```
abstract interface class IThaiAddressRepository {
  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// `true` once [initialize] has completed successfully.
  bool get isInitialized;

  /// Populate the data source. Must be awaited before calling any other method.
  ///
  /// Calling this multiple times is safe—subsequent calls are no-ops if data
  /// is already loaded.
  Future<void> initialize({AssetBundle? bundle, bool useIsolate = true});

  // ─── Bulk accessors ───────────────────────────────────────────────────────

  List<Geography> get geographies;
  List<Province> get provinces;
  List<District> get districts;
  List<SubDistrict> get subDistricts;

  // ─── Point lookups ────────────────────────────────────────────────────────

  Geography? getGeographyById(int id);
  Province? getProvinceById(int id);
  District? getDistrictById(int id);
  SubDistrict? getSubDistrictById(int id);

  // ─── Cascading filters ────────────────────────────────────────────────────

  List<Province> getProvincesByGeography(int geographyId);
  List<District> getDistrictsByProvince(int provinceId);
  List<SubDistrict> getSubDistrictsByDistrict(int districtId);

  /// Returns the villages that belong to [subDistrictId].
  ///
  /// Village data is loaded **lazily** on first access; subsequent calls
  /// resolve instantly from cache.  Returns `Future` intentionally—callers
  /// must not block the UI thread while villages are being loaded.
  Future<List<Village>> getVillagesBySubDistrict(int subDistrictId);

  // ─── Zip-code ─────────────────────────────────────────────────────────────

  List<SubDistrict> getSubDistrictsByZipCode(String zipCode);

  // ─── Search / autocomplete ────────────────────────────────────────────────

  List<Province> searchProvinces(String query);
  List<District> searchDistricts(String query, {int? provinceId});
  List<SubDistrict> searchSubDistricts(String query, {int? districtId});

  /// Substring-match search across all villages.
  ///
  /// Returns a [Future] because village data may still be loading when the
  /// first search is issued.
  Future<List<VillageSuggestion>> searchVillages(
    String query, {
    int maxResults = 20,
  });

  /// Prefix-match search across all zip codes.
  List<ZipCodeSuggestion> searchZipCodes(String query, {int maxResults = 20});

  /// All unique zip codes sorted ascending — for static autocomplete lists.
  List<String> getAllZipCodes();

  /// Helper: resolve district + province for the given sub-district.
  Map<String, dynamic> getFullAddressFromSubDistrict(SubDistrict subDistrict);

  // ─── Memory management ────────────────────────────────────────────────────

  /// Evict the in-memory village cache to reclaim memory.
  ///
  /// The next call to [getVillagesBySubDistrict] or [searchVillages] will
  /// reload and re-index the village file.
  void clearVillageCache();
}
