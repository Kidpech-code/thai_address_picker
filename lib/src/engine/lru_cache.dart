/// A generic Least Recently Used (LRU) cache with a fixed maximum size.
///
/// When the cache exceeds [maxSize], the least recently accessed entry
/// is evicted. Both [get] and [put] operations are O(1) amortized,
/// backed by Dart's [LinkedHashMap] which maintains insertion order.
///
/// ### Usage in the Search Engine
///
/// The [ThaiAddressSearchEngine] uses this to cache search results:
/// - Repeated queries (e.g., user backspacing and retyping) hit cache
///   instead of re-running trigram intersection and scoring.
/// - The cache is invalidated when the index is rebuilt.
///
/// ```dart
/// final cache = LruCache<String, List<Result>>(maxSize: 128);
///
/// var results = cache.get('บางนา');
/// if (results == null) {
///   results = engine.computeSearch('บางนา');
///   cache.put('บางนา', results);
/// }
/// ```
library;

import 'dart:collection';

class LruCache<K, V> {
  /// Maximum number of entries before eviction kicks in.
  final int maxSize;

  /// Insertion-ordered map. The first entry is the least recently used.
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  /// Create a cache with the given [maxSize].
  ///
  /// [maxSize] must be positive. Defaults to 64 entries.
  LruCache({this.maxSize = 64}) : assert(maxSize > 0, 'maxSize must be > 0');

  /// Retrieve a cached value by [key], or `null` if not present.
  ///
  /// Accessing a key promotes it to most-recently-used position.
  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // Re-insert at end (most recent)
    }
    return value;
  }

  /// Store a [key]–[value] pair, evicting the LRU entry if at capacity.
  ///
  /// If [key] already exists, its value is updated and it is promoted
  /// to the most-recently-used position.
  void put(K key, V value) {
    _cache.remove(key); // Remove old position if exists
    _cache[key] = value; // Insert at end (most recent)
    _evictIfNeeded();
  }

  /// Remove a specific [key] from the cache.
  ///
  /// Returns the removed value, or `null` if the key wasn't present.
  V? remove(K key) => _cache.remove(key);

  /// Whether the cache contains an entry for [key].
  bool containsKey(K key) => _cache.containsKey(key);

  /// Clear all cached entries.
  void clear() => _cache.clear();

  /// Current number of cached entries.
  int get length => _cache.length;

  /// Whether the cache is empty.
  bool get isEmpty => _cache.isEmpty;

  /// Whether the cache is at maximum capacity.
  bool get isFull => _cache.length >= maxSize;

  /// Evict least recently used entries until within capacity.
  void _evictIfNeeded() {
    while (_cache.length > maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }
}
