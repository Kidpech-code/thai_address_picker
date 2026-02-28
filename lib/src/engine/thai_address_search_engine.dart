import '../core/exceptions.dart';
import '../models/address_entry.dart';
import '../models/village_entry.dart';
import '../models/search_result.dart';
import 'trigram_index.dart';
import 'query_parser.dart';
import 'lru_cache.dart';

/// High-performance search engine for Thai address data.
///
/// ### Architecture
///
/// ```
/// ┌─────────────┐    buildIndex()    ┌──────────────────┐
/// │ Repository   │──────────────────▶│  SearchEngine     │
/// │ (7,452       │   List<Address    │                   │
/// │  entries)    │    Entry>         │  ┌─────────────┐  │
/// └─────────────┘                   │  │TrigramIndex  │  │
///                                   │  │ ~50K keys    │  │
///       search("บางนา 10")          │  └─────────────┘  │
///          │                        │  ┌─────────────┐  │
///          ▼                        │  │ZipPrefixIdx  │  │
///   ┌──────────────┐                │  │ ~1,600 keys  │  │
///   │ QueryParser  │                │  └─────────────┘  │
///   │ text:["บางนา"]│               │  ┌─────────────┐  │
///   │ zip: ["10"]  │──────────────▶ │  │ LRU Cache    │  │
///   └──────────────┘                │  │ 128 entries  │  │
///          │                        │  └─────────────┘  │
///          ▼                        └──────────────────┘
///   ┌──────────────┐                        │
///   │ Trigram ∩ Zip │                        ▼
///   │ Intersection  │              ┌──────────────────┐
///   └──────┬───────┘              │ Scored, Sorted   │
///          │                      │ Results          │
///          ▼                      └──────────────────┘
///   ┌──────────────┐
///   │ Score + Rank  │
///   └──────────────┘
/// ```
///
/// ### Search Pipeline
///
/// 1. **Parse** — [QueryParser] splits input into text terms and zip terms.
/// 2. **Cache check** — [LruCache] returns cached results for repeated queries.
/// 3. **Filter** — Text terms hit the [TrigramIndex]; zip terms hit the
///    prefix index. Results are intersected (AND logic).
/// 4. **Score** — Each candidate is scored by match quality
///    (exact > prefix > contains).
/// 5. **Rank** — Results sorted by score descending, trimmed to [maxResults].
/// 6. **Cache store** — Results cached for future identical queries.
///
/// ### Performance Characteristics
///
/// | Operation          | Complexity          | Typical Time (7,452 entries) |
/// |--------------------|---------------------|------------------------------|
/// | buildIndex()       | O(N × L)            | ~30–50ms                     |
/// | search() (cold)    | O(T × K + R log R)  | ~1–3ms                       |
/// | search() (cached)  | O(1)                | <0.01ms                      |
///
/// Where N=entries, L=avg field length, T=query trigrams, K=posting list
/// size, R=result count.
class ThaiAddressSearchEngine {
  // ─── Internal Indexes ──────────────────────────────────────────────────

  /// Trigram inverted index over all text fields of address entries.
  final TrigramIndex _trigramIndex = TrigramIndex();

  /// Zip code prefix index: prefix string → set of entry indices.
  ///
  /// For each entry, all prefixes of its zip code (length 1–5) are indexed.
  /// Example: zip "10260" → keys "1", "10", "102", "1026", "10260".
  final Map<String, Set<int>> _zipPrefixIndex = {};

  /// LRU cache for search results.
  final LruCache<String, List<AddressSearchResult>> _cache;

  // ─── Village Index (Lazy) ──────────────────────────────────────────────

  /// Trigram index for village names. Built lazily on first village search.
  TrigramIndex? _villageTrigramIndex;

  /// Flat village list matching the village trigram index's document IDs.
  List<VillageEntry>? _villageEntries;

  /// Mapping from subDistrictId → AddressEntry for village context resolution.
  Map<int, AddressEntry>? _subDistrictLookup;

  // ─── State ─────────────────────────────────────────────────────────────

  /// Master entries list. Populated by [buildIndex].
  List<AddressEntry> _entries = const [];

  /// Whether the address index has been built.
  bool _isBuilt = false;

  // ─── Constructor ───────────────────────────────────────────────────────

  /// Create a search engine with the given [cacheSize].
  ///
  /// The engine is not usable until [buildIndex] is called.
  ThaiAddressSearchEngine({int cacheSize = 128})
    : _cache = LruCache(maxSize: cacheSize);

  // ─── Public Getters ────────────────────────────────────────────────────

  /// Whether the engine is ready to accept search queries.
  bool get isReady => _isBuilt;

  /// Number of address entries in the index.
  int get entryCount => _entries.length;

  /// Number of unique trigrams in the index.
  int get trigramCount => _trigramIndex.trigramCount;

  /// Whether the village index has been built.
  bool get isVillageIndexReady => _villageTrigramIndex != null;

  // ─── Index Building ────────────────────────────────────────────────────

  /// Build the search index from flattened address entries.
  ///
  /// This should be called once after the repository's [initialize] completes.
  /// For ~7,452 entries, this takes ~30–50ms on a mid-range device.
  ///
  /// Calling [buildIndex] again replaces the existing index and clears
  /// the cache. The village index (if built) is also cleared.
  ///
  /// ```dart
  /// final repo = ThaiAddressJsonRepository();
  /// await repo.initialize();
  ///
  /// final engine = ThaiAddressSearchEngine();
  /// engine.buildIndex(repo.entries);
  ///
  /// final results = engine.search('บางนา');
  /// ```
  void buildIndex(List<AddressEntry> entries) {
    _entries = entries;
    _trigramIndex.clear();
    _zipPrefixIndex.clear();
    _cache.clear();
    _clearVillageIndex();

    // Build sub-district lookup for village context
    _subDistrictLookup = {
      for (final entry in entries) entry.subDistrictId: entry,
    };

    for (final entry in entries) {
      // ── Trigram index: all searchable text fields ──
      _trigramIndex.addDocument(entry.index, [
        entry.subDistrictTh,
        entry.subDistrictEn,
        entry.districtTh,
        entry.districtEn,
        entry.provinceTh,
        entry.provinceEn,
        entry.zipCode,
      ]);

      // ── Zip prefix index: all prefixes of the zip code ──
      final zip = entry.zipCode;
      for (var len = 1; len <= zip.length; len++) {
        final prefix = zip.substring(0, len);
        (_zipPrefixIndex[prefix] ??= {}).add(entry.index);
      }
    }

    _isBuilt = true;
  }

  // ─── Address Search ────────────────────────────────────────────────────

  /// Search addresses with multi-term, multi-field matching.
  ///
  /// ### Supported Query Patterns
  ///
  /// | Query              | Behavior                                     |
  /// |--------------------|----------------------------------------------|
  /// | `"บางนา"`          | Trigram match across all Thai name fields     |
  /// | `"Bang Na"`        | Trigram match across English name fields      |
  /// | `"10260"`          | Exact/prefix zip code match                  |
  /// | `"บางนา 10"`       | AND intersection: text + zip prefix          |
  /// | `"กรุงเทพ พระนคร"` | AND intersection: both text terms must match |
  ///
  /// ### Parameters
  ///
  /// - [query] — Raw user input. Whitespace-separated terms are ANDed.
  /// - [maxResults] — Maximum number of results to return (default: 20).
  ///
  /// ### Returns
  ///
  /// A list of [AddressSearchResult] sorted by relevance score (highest
  /// first). Returns an empty list for blank queries.
  ///
  /// ### Throws
  ///
  /// - [AddressSearchException] if the engine is not initialized or
  ///   an unexpected error occurs during search.
  List<AddressSearchResult> search(String query, {int maxResults = 20}) {
    _ensureBuilt(query);

    final parsed = QueryParser.parse(query);
    if (parsed.isEmpty) return const [];

    // ── Cache hit ──
    final cacheKey = '${parsed.raw}|$maxResults';
    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;

    try {
      final results = _executeSearch(parsed, maxResults);
      _cache.put(cacheKey, results);
      return results;
    } catch (e, st) {
      if (e is AddressSearchException) rethrow;
      throw AddressSearchException(
        'Search failed unexpectedly',
        query: query,
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ─── Village Search ────────────────────────────────────────────────────

  /// Build the village trigram index from a list of [VillageEntry].
  ///
  /// Call this after loading village data from the repository.
  /// For ~82,000 villages, this takes ~200–400ms (offload to isolate
  /// if needed via the repository layer).
  void buildVillageIndex(List<VillageEntry> villages) {
    _villageEntries = villages;
    _villageTrigramIndex = TrigramIndex();

    for (var i = 0; i < villages.length; i++) {
      _villageTrigramIndex!.addDocument(i, [villages[i].nameTh]);
    }
  }

  /// Search villages by name with scored results.
  ///
  /// Returns [VillageSearchResult] with parent address context
  /// resolved from the main address index.
  ///
  /// Throws [AddressSearchException] if the village index hasn't been built.
  List<VillageSearchResult> searchVillages(
    String query, {
    int maxResults = 20,
  }) {
    if (_villageTrigramIndex == null || _villageEntries == null) {
      throw AddressSearchException(
        'Village index not built. Call buildVillageIndex() first.',
        query: query,
      );
    }

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];

    final candidates = _villageTrigramIndex!.query(trimmed);
    if (candidates.isEmpty) return const [];

    final villages = _villageEntries!;
    final results = <VillageSearchResult>[];

    for (final idx in candidates) {
      if (results.length >= maxResults * 2) break; // Over-fetch for scoring
      final village = villages[idx];
      final score = _scoreVillageMatch(village, trimmed);
      final parent = _subDistrictLookup?[village.subDistrictId];
      results.add(
        VillageSearchResult(
          village: village,
          parentAddress: parent,
          score: score,
        ),
      );
    }

    results.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.village.nameTh.compareTo(b.village.nameTh);
    });

    return results.length > maxResults
        ? results.sublist(0, maxResults)
        : results;
  }

  // ─── Cache Management ──────────────────────────────────────────────────

  /// Clear the search result cache.
  ///
  /// Call this when the underlying data changes (rare for static
  /// address data, but useful for testing).
  void clearCache() => _cache.clear();

  // ─── Lifecycle ─────────────────────────────────────────────────────────

  /// Release all resources held by the search engine.
  ///
  /// After calling [dispose], the engine is not usable. Create a new
  /// instance and call [buildIndex] to reinitialize.
  void dispose() {
    _trigramIndex.clear();
    _zipPrefixIndex.clear();
    _cache.clear();
    _clearVillageIndex();
    _subDistrictLookup = null;
    _entries = const [];
    _isBuilt = false;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PRIVATE IMPLEMENTATION
  // ═══════════════════════════════════════════════════════════════════════

  // ─── Core Search Logic ─────────────────────────────────────────────────

  List<AddressSearchResult> _executeSearch(ParsedQuery parsed, int maxResults) {
    // Phase 1: Collect candidate entry indices via index intersection
    Set<int>? candidates;

    // ── Text terms → trigram index ──
    for (final term in parsed.textTerms) {
      final hits = _trigramIndex.query(term);
      candidates = candidates == null ? hits : candidates.intersection(hits);
      if (candidates.isEmpty) break;
    }

    // ── Zip terms → prefix index ──
    for (final zip in parsed.zipTerms) {
      final hits = _zipPrefixIndex[zip] ?? const {};
      candidates = candidates == null ? hits : candidates.intersection(hits);
      if (candidates.isEmpty) break;
    }

    if (candidates == null || candidates.isEmpty) return const [];

    // Phase 2: Score each candidate
    final scored = <AddressSearchResult>[];
    for (final idx in candidates) {
      final entry = _entries[idx];
      final score = _computeScore(entry, parsed);
      scored.add(AddressSearchResult(entry: entry, score: score));
    }

    // Phase 3: Sort by score descending, then alphabetically
    scored.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.entry.subDistrictTh.compareTo(b.entry.subDistrictTh);
    });

    // Phase 4: Trim and return
    return scored.length > maxResults ? scored.sublist(0, maxResults) : scored;
  }

  // ─── Scoring ───────────────────────────────────────────────────────────

  /// Compute a relevance score for [entry] against [parsed] query.
  ///
  /// Scoring heuristics (additive per term):
  /// - Exact field match: +100
  /// - Prefix match: +60
  /// - Contains match: +20
  /// - Exact zip: +100
  /// - Zip prefix: +50 + (prefix_length × 10)
  double _computeScore(AddressEntry entry, ParsedQuery parsed) {
    double score = 0;

    // ── Score text terms ──
    for (final term in parsed.textTerms) {
      final lower = term.toLowerCase();
      score += _scoreTextMatch(entry, lower);
    }

    // ── Score zip terms ──
    for (final zip in parsed.zipTerms) {
      if (entry.zipCode == zip) {
        score += 100; // Exact zip match
      } else if (entry.zipCode.startsWith(zip)) {
        // Longer prefix matches score higher (e.g., "1026" > "102" > "10")
        score += 50 + (zip.length * 10);
      }
    }

    return score;
  }

  /// Score a single text term against all fields of an entry.
  double _scoreTextMatch(AddressEntry entry, String lowerTerm) {
    // Check exact match first (highest value)
    if (_isExactFieldMatch(entry, lowerTerm)) return 100;

    // Check prefix match
    if (_isPrefixFieldMatch(entry, lowerTerm)) return 60;

    // Check contains match (catches trigram-matched but non-prefix results)
    if (entry.searchText.contains(lowerTerm)) return 20;

    // Trigram matched but the full term doesn't appear as a substring.
    // This can happen with overlapping trigrams. Give minimal score.
    return 5;
  }

  /// Check if [lowerTerm] exactly matches any searchable field.
  bool _isExactFieldMatch(AddressEntry entry, String lowerTerm) =>
      entry.subDistrictTh.toLowerCase() == lowerTerm ||
      entry.subDistrictEn.toLowerCase() == lowerTerm ||
      entry.districtTh.toLowerCase() == lowerTerm ||
      entry.districtEn.toLowerCase() == lowerTerm ||
      entry.provinceTh.toLowerCase() == lowerTerm ||
      entry.provinceEn.toLowerCase() == lowerTerm;

  /// Check if [lowerTerm] is a prefix of any searchable field.
  bool _isPrefixFieldMatch(AddressEntry entry, String lowerTerm) =>
      entry.subDistrictTh.toLowerCase().startsWith(lowerTerm) ||
      entry.subDistrictEn.toLowerCase().startsWith(lowerTerm) ||
      entry.districtTh.toLowerCase().startsWith(lowerTerm) ||
      entry.districtEn.toLowerCase().startsWith(lowerTerm) ||
      entry.provinceTh.toLowerCase().startsWith(lowerTerm) ||
      entry.provinceEn.toLowerCase().startsWith(lowerTerm);

  // ─── Village Scoring ───────────────────────────────────────────────────

  double _scoreVillageMatch(VillageEntry village, String lowerQuery) {
    final nameLower = village.nameTh.toLowerCase();
    if (nameLower == lowerQuery) return 100;
    if (nameLower.startsWith(lowerQuery)) return 60;
    if (nameLower.contains(lowerQuery)) return 20;
    return 5;
  }

  // ─── Guards ────────────────────────────────────────────────────────────

  void _ensureBuilt(String query) {
    if (!_isBuilt) {
      throw AddressSearchException(
        'Search engine not initialized. Call buildIndex() first.',
        query: query,
      );
    }
  }

  void _clearVillageIndex() {
    _villageTrigramIndex?.clear();
    _villageTrigramIndex = null;
    _villageEntries = null;
  }
}
