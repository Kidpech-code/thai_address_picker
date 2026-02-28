import 'package:flutter/foundation.dart';

/// Represents a parsed multi-term search query with classified tokens.
///
/// The [QueryParser] splits raw user input into:
/// - **[textTerms]** — Thai/English text fragments for trigram matching
/// - **[zipTerms]** — digit-only fragments for zip code prefix matching
///
/// This classification allows the search engine to route each term to
/// the optimal index (trigram index vs. zip prefix index).
///
/// ```dart
/// final parsed = QueryParser.parse('บางนา 10260');
/// print(parsed.textTerms); // ['บางนา']
/// print(parsed.zipTerms);  // ['10260']
/// print(parsed.isEmpty);   // false
/// ```
@immutable
class ParsedQuery {
  /// All non-empty tokens extracted from the raw input.
  final List<String> terms;

  /// Tokens that consist entirely of digits (potential zip codes).
  final List<String> zipTerms;

  /// Tokens that contain non-digit characters (Thai/English text).
  final List<String> textTerms;

  /// The original raw input string (trimmed).
  final String raw;

  const ParsedQuery({
    required this.terms,
    required this.zipTerms,
    required this.textTerms,
    required this.raw,
  });

  /// An empty query with no terms.
  static const ParsedQuery empty = ParsedQuery(
    terms: [],
    zipTerms: [],
    textTerms: [],
    raw: '',
  );

  /// Whether the query has no usable terms.
  bool get isEmpty => terms.isEmpty;

  /// Whether the query has at least one usable term.
  bool get isNotEmpty => terms.isNotEmpty;

  /// Whether the query contains any zip-code-like terms.
  bool get hasZipTerms => zipTerms.isNotEmpty;

  /// Whether the query contains any text terms.
  bool get hasTextTerms => textTerms.isNotEmpty;

  @override
  String toString() =>
      'ParsedQuery(text: $textTerms, zip: $zipTerms, raw: "$raw")';
}

// ─────────────────────────────────────────────────────────────────────────────
// QueryParser
// ─────────────────────────────────────────────────────────────────────────────

/// Tokenizes and classifies raw search input into a [ParsedQuery].
///
/// ### Tokenization Rules
///
/// 1. Split on whitespace (supports any Unicode whitespace).
/// 2. Discard empty tokens.
/// 3. Classify each token:
///    - **Zip term** if it matches `^\d{1,5}$` (1–5 digits).
///    - **Text term** otherwise.
///
/// ### Thai-Specific Considerations
///
/// Thai text doesn't use spaces between words, so a single token like
/// "บางนาใต้" is kept as one unit and matched via trigram decomposition.
/// The parser does NOT attempt Thai word segmentation — that's the
/// trigram index's job.
///
/// ### Examples
///
/// | Input                  | Text Terms         | Zip Terms  |
/// |------------------------|--------------------|------------|
/// | `"บางนา"`              | `["บางนา"]`        | `[]`       |
/// | `"10260"`              | `[]`               | `["10260"]`|
/// | `"บางนา 10"`           | `["บางนา"]`        | `["10"]`   |
/// | `"Bang Na 10260"`      | `["bang", "na"]`   | `["10260"]`|
/// | `"  กรุงเทพ  มหานคร "` | `["กรุงเทพ", "มหานคร"]` | `[]` |
class QueryParser {
  // Private constructor — this is a static utility class.
  QueryParser._();

  /// Matches a string consisting of 1–5 digits only.
  static final RegExp _zipPattern = RegExp(r'^\d{1,5}$');

  /// Matches one or more whitespace characters (Unicode-aware).
  static final RegExp _whitespace = RegExp(r'\s+');

  /// Parse raw user input into a classified [ParsedQuery].
  ///
  /// Returns [ParsedQuery.empty] for blank input.
  static ParsedQuery parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return ParsedQuery.empty;

    final tokens = trimmed
        .split(_whitespace)
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return ParsedQuery.empty;

    final zipTerms = <String>[];
    final textTerms = <String>[];

    for (final token in tokens) {
      if (_zipPattern.hasMatch(token)) {
        zipTerms.add(token);
      } else {
        textTerms.add(token);
      }
    }

    return ParsedQuery(
      terms: tokens,
      zipTerms: zipTerms,
      textTerms: textTerms,
      raw: trimmed,
    );
  }
}
