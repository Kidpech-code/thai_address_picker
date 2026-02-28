/// Custom exception classes for the Thai Address Picker package.
///
/// These provide granular error handling and clear error messages
/// for enterprise-grade error boundaries. Catch these at the widget
/// level to display user-friendly error states instead of crashing.
library;

// ─────────────────────────────────────────────────────────────────────────────
// AddressInitializationException
// ─────────────────────────────────────────────────────────────────────────────

/// Thrown when the address data source fails to initialize.
///
/// Common causes:
/// - Asset bundle not found (incorrect package configuration)
/// - Corrupted or malformed JSON data files
/// - Insufficient memory to parse data on low-end devices
///
/// ```dart
/// try {
///   await repository.initialize();
/// } on AddressInitializationException catch (e) {
///   logger.error('Address init failed', error: e.cause);
///   showErrorSnackbar('ไม่สามารถโหลดข้อมูลที่อยู่ได้');
/// }
/// ```
class AddressInitializationException implements Exception {
  /// Human-readable description of the initialization failure.
  final String message;

  /// The underlying error that caused initialization to fail, if any.
  final Object? cause;

  /// Stack trace of the underlying error, if available.
  final StackTrace? stackTrace;

  const AddressInitializationException(
    this.message, {
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AddressInitializationException: $message');
    if (cause != null) buffer.write('\nCaused by: $cause');
    if (stackTrace != null) buffer.write('\n$stackTrace');
    return buffer.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AddressSearchException
// ─────────────────────────────────────────────────────────────────────────────

/// Thrown when a search operation fails unexpectedly.
///
/// This should not occur during normal operation. If thrown, it typically
/// indicates an internal bug in the search engine or an uninitialized index.
///
/// ```dart
/// try {
///   final results = engine.search('บางนา');
/// } on AddressSearchException catch (e) {
///   debugPrint('Search failed for "${e.query}": ${e.message}');
///   return const []; // Graceful degradation
/// }
/// ```
class AddressSearchException implements Exception {
  /// Human-readable description of the search failure.
  final String message;

  /// The query string that triggered the failure, if available.
  final String? query;

  /// The underlying error, if any.
  final Object? cause;

  /// Stack trace of the underlying error, if available.
  final StackTrace? stackTrace;

  const AddressSearchException(
    this.message, {
    this.query,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AddressSearchException: $message');
    if (query != null) buffer.write('\nQuery: "$query"');
    if (cause != null) buffer.write('\nCaused by: $cause');
    if (stackTrace != null) buffer.write('\n$stackTrace');
    return buffer.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AddressDataException
// ─────────────────────────────────────────────────────────────────────────────

/// Thrown when address data is in an unexpected format or state.
///
/// Indicates data integrity issues such as:
/// - Missing required JSON fields
/// - Referential integrity violations (e.g., district references
///   a province ID that doesn't exist)
/// - Data accessed before initialization completes
class AddressDataException implements Exception {
  /// Human-readable description of the data issue.
  final String message;

  /// The underlying error, if any.
  final Object? cause;

  const AddressDataException(this.message, {this.cause});

  @override
  String toString() {
    final buffer = StringBuffer('AddressDataException: $message');
    if (cause != null) buffer.write('\nCaused by: $cause');
    return buffer.toString();
  }
}
