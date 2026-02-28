/// A trigram-based inverted index for sub-linear substring matching.
///
/// ### Algorithm
///
/// 1. **Indexing** — For each document (identified by an integer ID), extract
///    all trigrams (3-character substrings) from its searchable fields and
///    store the document ID in a **posting list** for each trigram.
///
/// 2. **Querying** — For a query string, extract its trigrams, look up each
///    trigram's posting list, and **intersect** all lists to find documents
///    containing ALL query trigrams.
///
/// ### Complexity
///
/// | Operation        | Time                | Space           |
/// |------------------|---------------------|-----------------|
/// | Index 1 doc      | O(L) per field      | O(L) trigrams   |
/// | Query            | O(T × log K)        | O(min K)        |
///
/// Where L = field length, T = query trigrams, K = posting list size.
///
/// ### Why Trigrams for Thai Text?
///
/// Thai script presents unique challenges for search algorithms:
///
/// 1. **No word boundaries** — Thai doesn't use spaces between words within
///    a phrase (e.g., "กรุงเทพมหานคร" is one continuous string). A Trie only
///    supports prefix matching, missing substring queries entirely.
///
/// 2. **High Unicode fanout** — Thai has ~100+ unique characters (ก-ฮ,
///    vowels, tone marks). Each Trie node would need ~100+ child pointers,
///    wasting memory compared to a hash-based trigram map.
///
/// 3. **Natural sub-word capture** — Trigrams like "กรุ", "รุง", "งเท"
///    naturally capture sub-word patterns in both Thai and English text,
///    enabling partial matching from any position.
///
/// 4. **Multi-term intersection** — Users type "บางนา 10260"; trigrams
///    from "บางนา" and "10260" each produce a candidate set, and their
///    intersection gives precise results in O(min set size).
///
/// ### Memory Profile
///
/// For ~7,452 sub-district entries with ~5 fields each:
/// - Unique trigram keys: ~40,000–60,000
/// - Posting lists: sorted integer arrays (16-bit values suffice)
/// - Total index memory: ~2–3 MB
library;

class TrigramIndex {
  /// Inverted index: trigram → sorted list of document IDs.
  final Map<String, List<int>> _postings = {};

  /// Number of documents indexed.
  int _documentCount = 0;

  /// Number of documents currently indexed.
  int get documentCount => _documentCount;

  /// Number of unique trigram keys in the index.
  int get trigramCount => _postings.length;

  // ─── Indexing ──────────────────────────────────────────────────────────

  /// Index a document with the given [docId] and searchable [fields].
  ///
  /// [docId] must be sequential starting from 0 (matching the entry's
  /// array index). Each field string is lowercased and decomposed into
  /// trigrams. The docId is added to the posting list for each trigram.
  ///
  /// Duplicate docIds within a posting list are harmless — they are
  /// collapsed during the query phase's Set conversion.
  void addDocument(int docId, List<String> fields) {
    _documentCount = docId + 1;
    final seen = <String>{};

    for (final field in fields) {
      if (field.isEmpty) continue;
      final lower = field.toLowerCase();
      final trigrams = extractTrigrams(lower);

      for (final trigram in trigrams) {
        // Deduplicate within this document to save memory
        if (seen.add('$trigram\x00$docId')) {
          (_postings[trigram] ??= []).add(docId);
        }
      }

      // Also index bigrams for 2-character fields (e.g., short Thai names)
      if (lower.length == 2) {
        if (seen.add('$lower\x00$docId')) {
          (_postings[lower] ??= []).add(docId);
        }
      }
    }
  }

  // ─── Querying ──────────────────────────────────────────────────────────

  /// Find all document IDs matching the [searchTerm].
  ///
  /// For terms with ≥3 characters: extracts trigrams, looks up each
  /// trigram's posting list, and intersects them. For shorter terms,
  /// falls back to a trigram-key scan.
  ///
  /// Returns an empty set if no documents match.
  Set<int> query(String searchTerm) {
    final lower = searchTerm.toLowerCase().trim();
    if (lower.isEmpty) return const {};

    final trigrams = extractTrigrams(lower);
    if (trigrams.isEmpty) {
      // Query is 1–2 characters: fall back to scanning trigram keys
      return _shortTermQuery(lower);
    }

    // Sort posting lists by length (shortest first) for minimal intersection
    final lists =
        trigrams
            .map((t) => _postings[t])
            .where((list) => list != null)
            .cast<List<int>>()
            .toList()
          ..sort((a, b) => a.length.compareTo(b.length));

    // If any trigram has zero postings, no results
    if (lists.length < trigrams.length) return const {};
    if (lists.isEmpty) return const {};

    // Progressive intersection starting from the smallest list
    Set<int> result = lists.first.toSet();
    for (var i = 1; i < lists.length && result.isNotEmpty; i++) {
      result = result.intersection(lists[i].toSet());
    }

    return result;
  }

  // ─── Trigram Extraction ────────────────────────────────────────────────

  /// Extract all trigrams (3-character substrings) from [text].
  ///
  /// For "กรุงเทพ" → ["กรุ", "รุง", "งเท", "เทพ"]
  ///
  /// Returns an empty list if text has fewer than 3 characters.
  static List<String> extractTrigrams(String text) {
    if (text.length < 3) return const [];
    final trigrams = <String>[];
    for (var i = 0; i <= text.length - 3; i++) {
      trigrams.add(text.substring(i, i + 3));
    }
    return trigrams;
  }

  // ─── Short-Term Fallback ───────────────────────────────────────────────

  /// For 1–2 character queries, scan trigram keys for containment.
  ///
  /// This is O(K) where K = number of unique trigrams (~50K), which
  /// completes in <1ms. Only triggered for very short queries.
  Set<int> _shortTermQuery(String text) {
    // First check direct posting (for indexed bigrams)
    final direct = _postings[text];
    if (direct != null) return direct.toSet();

    // Scan trigram keys
    final results = <int>{};
    for (final entry in _postings.entries) {
      if (entry.key.contains(text)) {
        results.addAll(entry.value);
      }
    }
    return results;
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────

  /// Clear all indexed data and reset document count.
  void clear() {
    _postings.clear();
    _documentCount = 0;
  }
}
