import 'package:flutter/services.dart';

import '../models/address_entry.dart';
import '../models/village_entry.dart';

/// Contract for the Thai address data layer (v2 — Enterprise Architecture).
///
/// This interface decouples the [ThaiAddressSearchEngine] and UI widgets
/// from the underlying data source. Implementations can be:
///
/// - **Asset JSON** — default, loads bundled JSON assets (Phase 2)
/// - **SQLite/FTS5** — on-disk querying for extreme datasets
/// - **Remote API** — for centralized address management
/// - **In-memory mock** — for unit / widget tests
///
/// ### Design Principles
///
/// 1. **Flat data model** — serves [AddressEntry] (flattened province +
///    district + sub-district) instead of separate entity lists, eliminating
///    the need for relationship resolution at query time.
///
/// 2. **Lazy village loading** — the ~82,000 village records are loaded
///    only on demand and evictable via [clearVillageCache].
///
/// 3. **Isolate-safe** — [initialize] offloads heavy JSON parsing to
///    a background isolate to maintain 60fps on the main thread.
///
/// ```dart
/// // Production
/// final repo = ThaiAddressJsonRepository();
/// await repo.initialize();
/// engine.buildIndex(repo.entries);
///
/// // Testing
/// class FakeRepo implements IAddressRepository {
///   @override bool get isInitialized => true;
///   @override List<AddressEntry> get entries => [...testEntries];
///   // ...stub remaining methods
/// }
/// ```
abstract interface class IAddressRepository {
  // ─── Lifecycle ────────────────────────────────────────────────────────

  /// `true` once [initialize] has completed successfully.
  bool get isInitialized;

  /// Populate the data source. Must be awaited before accessing [entries].
  ///
  /// - Calling multiple times is safe — subsequent calls are no-ops.
  /// - Pass a custom [bundle] for testing or flavor-specific assets.
  /// - Throws [AddressInitializationException] on failure.
  Future<void> initialize({AssetBundle? bundle});

  // ─── Core Data ────────────────────────────────────────────────────────

  /// All flattened address entries (one per sub-district).
  ///
  /// Typically ~7,452 entries for Thailand's administrative structure.
  /// Entries are indexed sequentially: `entries[entry.index] == entry`.
  ///
  /// Throws [AddressDataException] if called before [initialize].
  List<AddressEntry> get entries;

  // ─── Point Lookups ────────────────────────────────────────────────────

  /// O(1) lookup of an entry by its sub-district ID.
  ///
  /// Returns `null` if the ID doesn't exist.
  AddressEntry? getEntryBySubDistrictId(int subDistrictId);

  // ─── Filtered Access ──────────────────────────────────────────────────

  /// All entries belonging to the given province.
  List<AddressEntry> getEntriesByProvinceId(int provinceId);

  /// All entries belonging to the given district.
  List<AddressEntry> getEntriesByDistrictId(int districtId);

  /// Unique province names (Thai) for province-level filtering.
  ///
  /// Returns `[{id, nameTh, nameEn}]` derived from [entries].
  /// Use this when you need a province dropdown without separate Province objects.
  List<({int id, String nameTh, String nameEn})> get uniqueProvinces;

  /// Unique district names for a given province.
  List<({int id, String nameTh, String nameEn})> getUniqueDistrictsByProvinceId(
    int provinceId,
  );

  // ─── Village Access (Lazy) ────────────────────────────────────────────

  /// Get villages for a specific sub-district. Lazy-loaded on first access.
  ///
  /// Returns a [Future] because village data may still be loading.
  Future<List<VillageEntry>> getVillagesBySubDistrictId(int subDistrictId);

  /// Get ALL villages. Use with care — ~82,000 records.
  ///
  /// Intended for building the village search index. Returns a [Future]
  /// because village loading is deferred.
  Future<List<VillageEntry>> getAllVillages();

  // ─── Memory Management ───────────────────────────────────────────────

  /// Evict the in-memory village cache to reclaim memory.
  ///
  /// The next call to [getVillagesBySubDistrictId] or [getAllVillages]
  /// will reload from the data source.
  void clearVillageCache();

  /// Release all resources held by the repository.
  ///
  /// After calling [dispose], the repository is no longer usable.
  /// Call [initialize] again to reinitialize if needed.
  void dispose();
}
