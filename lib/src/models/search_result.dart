import 'package:flutter/foundation.dart';

import 'address_entry.dart';
import 'village_entry.dart';

/// A scored search result wrapping an [AddressEntry].
///
/// Returned by [ThaiAddressSearchEngine.search]. Results are sorted by
/// [score] descending — higher scores indicate better relevance.
///
/// ### Scoring Heuristics
///
/// | Match Type                | Score  |
/// |---------------------------|--------|
/// | Exact field match         | +100   |
/// | Prefix match              | +60    |
/// | Contains / substring      | +20    |
/// | Exact zip code            | +100   |
/// | Zip prefix (per digit)    | +50 + length×10 |
///
/// Scores are additive across multiple query terms, so multi-term
/// queries that match multiple fields score higher.
@immutable
class AddressSearchResult {
  /// The matched address entry.
  final AddressEntry entry;

  /// Relevance score computed by the search engine.
  /// Higher is more relevant. Range: 0.0 – ~400.0+.
  final double score;

  /// Optional highlight ranges for UI rendering.
  ///
  /// Each [TextHighlight] identifies a field name and the character
  /// range that matched the query. Populated only when the engine
  /// is configured with `highlightMatches: true` (future feature).
  final List<TextHighlight>? highlights;

  const AddressSearchResult({
    required this.entry,
    required this.score,
    this.highlights,
  });

  @override
  String toString() =>
      'AddressSearchResult(score: ${score.toStringAsFixed(1)}, '
      '${entry.fullAddressTh})';
}

/// Identifies a matched character range within a specific field.
///
/// Used for rendering highlighted search results in the UI, e.g.,
/// bolding the matched substring in a suggestion dropdown.
///
/// ```dart
/// // Highlight "บางนา" in "แขวงบางนา"
/// const highlight = TextHighlight(field: 'subDistrictTh', start: 4, end: 9);
/// ```
@immutable
class TextHighlight {
  /// The field name that contains the match (e.g., 'subDistrictTh').
  final String field;

  /// Start index (inclusive) of the match in the field value.
  final int start;

  /// End index (exclusive) of the match in the field value.
  final int end;

  const TextHighlight({
    required this.field,
    required this.start,
    required this.end,
  });

  @override
  String toString() => 'TextHighlight($field[$start:$end])';
}

/// A scored search result wrapping a [VillageEntry] with its
/// parent address context.
///
/// Returned by [ThaiAddressSearchEngine.searchVillages].
@immutable
class VillageSearchResult {
  /// The matched village.
  final VillageEntry village;

  /// The parent address entry for this village's sub-district.
  final AddressEntry? parentAddress;

  /// Relevance score. Higher is more relevant.
  final double score;

  const VillageSearchResult({
    required this.village,
    this.parentAddress,
    required this.score,
  });

  /// Full display string: village name • Moo • sub-district • district • province
  String get displayText {
    final parts = <String>[village.displayName];
    if (parentAddress != null) {
      parts.add(parentAddress!.subDistrictTh);
      parts.add(parentAddress!.districtTh);
      parts.add(parentAddress!.provinceTh);
    }
    return parts.join(' • ');
  }

  @override
  String toString() =>
      'VillageSearchResult(score: ${score.toStringAsFixed(1)}, '
      '${village.displayName})';
}
