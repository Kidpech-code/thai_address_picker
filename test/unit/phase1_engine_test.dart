import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/core/exceptions.dart';
import 'package:thai_address_picker/src/models/address_entry.dart';
import 'package:thai_address_picker/src/models/village_entry.dart';
import 'package:thai_address_picker/src/models/search_result.dart';
import 'package:thai_address_picker/src/engine/trigram_index.dart';
import 'package:thai_address_picker/src/engine/query_parser.dart';
import 'package:thai_address_picker/src/engine/lru_cache.dart';
import 'package:thai_address_picker/src/engine/thai_address_search_engine.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Test Data Factory
// ═══════════════════════════════════════════════════════════════════════════

/// Builds realistic test entries matching Thailand's address structure.
List<AddressEntry> _buildTestEntries() {
  return [
    AddressEntry(
      index: 0,
      provinceId: 1,
      districtId: 1001,
      subDistrictId: 100101,
      provinceTh: 'กรุงเทพมหานคร',
      provinceEn: 'Bangkok',
      districtTh: 'พระนคร',
      districtEn: 'Phra Nakhon',
      subDistrictTh: 'พระบรมมหาราชวัง',
      subDistrictEn: 'Phra Borom Maha Ratchawang',
      zipCode: '10200',
      lat: 13.751,
      lng: 100.492,
    ),
    AddressEntry(
      index: 1,
      provinceId: 1,
      districtId: 1001,
      subDistrictId: 100102,
      provinceTh: 'กรุงเทพมหานคร',
      provinceEn: 'Bangkok',
      districtTh: 'พระนคร',
      districtEn: 'Phra Nakhon',
      subDistrictTh: 'วังบูรพาภิรมย์',
      subDistrictEn: 'Wang Burapha Phirom',
      zipCode: '10200',
    ),
    AddressEntry(
      index: 2,
      provinceId: 1,
      districtId: 1039,
      subDistrictId: 103901,
      provinceTh: 'กรุงเทพมหานคร',
      provinceEn: 'Bangkok',
      districtTh: 'บางนา',
      districtEn: 'Bang Na',
      subDistrictTh: 'บางนา',
      subDistrictEn: 'Bang Na',
      zipCode: '10260',
      lat: 13.668,
      lng: 100.604,
    ),
    AddressEntry(
      index: 3,
      provinceId: 2,
      districtId: 2001,
      subDistrictId: 200101,
      provinceTh: 'นนทบุรี',
      provinceEn: 'Nonthaburi',
      districtTh: 'เมืองนนทบุรี',
      districtEn: 'Mueang Nonthaburi',
      subDistrictTh: 'สวนใหญ่',
      subDistrictEn: 'Suan Yai',
      zipCode: '11000',
    ),
    AddressEntry(
      index: 4,
      provinceId: 3,
      districtId: 3001,
      subDistrictId: 300101,
      provinceTh: 'เชียงใหม่',
      provinceEn: 'Chiang Mai',
      districtTh: 'เมืองเชียงใหม่',
      districtEn: 'Mueang Chiang Mai',
      subDistrictTh: 'ศรีภูมิ',
      subDistrictEn: 'Si Phum',
      zipCode: '50200',
    ),
    AddressEntry(
      index: 5,
      provinceId: 1,
      districtId: 1002,
      subDistrictId: 100201,
      provinceTh: 'กรุงเทพมหานคร',
      provinceEn: 'Bangkok',
      districtTh: 'ดุสิต',
      districtEn: 'Dusit',
      subDistrictTh: 'ดุสิต',
      subDistrictEn: 'Dusit',
      zipCode: '10300',
    ),
    AddressEntry(
      index: 6,
      provinceId: 1,
      districtId: 1004,
      subDistrictId: 100401,
      provinceTh: 'กรุงเทพมหานคร',
      provinceEn: 'Bangkok',
      districtTh: 'บางรัก',
      districtEn: 'Bang Rak',
      subDistrictTh: 'มหาพฤฒาราม',
      subDistrictEn: 'Maha Phruettharam',
      zipCode: '10500',
    ),
    AddressEntry(
      index: 7,
      provinceId: 4,
      districtId: 4001,
      subDistrictId: 400101,
      provinceTh: 'ภูเก็ต',
      provinceEn: 'Phuket',
      districtTh: 'เมืองภูเก็ต',
      districtEn: 'Mueang Phuket',
      subDistrictTh: 'ตลาดใหญ่',
      subDistrictEn: 'Talat Yai',
      zipCode: '83000',
    ),
  ];
}

List<VillageEntry> _buildTestVillages() {
  return [
    const VillageEntry(
      id: 1,
      nameTh: 'บ้านทุ่งนา',
      mooNo: 3,
      subDistrictId: 100101,
      lat: 13.751,
      lng: 100.492,
    ),
    const VillageEntry(
      id: 2,
      nameTh: 'บ้านหลังวัด',
      mooNo: 5,
      subDistrictId: 100101,
    ),
    const VillageEntry(
      id: 3,
      nameTh: 'บ้านคลองลาด',
      mooNo: 1,
      subDistrictId: 103901,
    ),
    const VillageEntry(
      id: 4,
      nameTh: 'บ้านท่าน้ำ',
      mooNo: 0,
      subDistrictId: 200101,
    ),
    const VillageEntry(
      id: 5,
      nameTh: 'บ้านทุ่งสวน',
      mooNo: 2,
      subDistrictId: 300101,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// Tests
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Exceptions
  // ─────────────────────────────────────────────────────────────────────────

  group('Custom Exceptions', () {
    test('AddressInitializationException formats correctly', () {
      const e = AddressInitializationException(
        'Asset bundle not found',
        cause: 'FileNotFoundError',
      );
      expect(e.toString(), contains('AddressInitializationException'));
      expect(e.toString(), contains('Asset bundle not found'));
      expect(e.toString(), contains('FileNotFoundError'));
      expect(e.message, 'Asset bundle not found');
      expect(e.cause, 'FileNotFoundError');
    });

    test('AddressSearchException includes query', () {
      const e = AddressSearchException('Index not built', query: 'บางนา');
      expect(e.toString(), contains('AddressSearchException'));
      expect(e.toString(), contains('บางนา'));
      expect(e.query, 'บางนา');
    });

    test('AddressDataException formats correctly', () {
      const e = AddressDataException('Malformed JSON');
      expect(e.toString(), contains('AddressDataException'));
      expect(e.toString(), contains('Malformed JSON'));
    });

    test('AddressInitializationException with stackTrace', () {
      final st = StackTrace.current;
      final e = AddressInitializationException('Failed', stackTrace: st);
      expect(e.stackTrace, st);
      expect(e.toString(), contains('Failed'));
    });

    test('AddressSearchException with cause and stackTrace', () {
      final cause = Exception('inner');
      final st = StackTrace.current;
      final e = AddressSearchException(
        'Unexpected',
        query: 'test',
        cause: cause,
        stackTrace: st,
      );
      expect(e.cause, cause);
      expect(e.stackTrace, st);
      expect(e.toString(), contains('Caused by'));
    });

    test('AddressDataException with cause', () {
      const e = AddressDataException('Bad data', cause: 'format error');
      expect(e.toString(), contains('Caused by'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AddressEntry Model
  // ─────────────────────────────────────────────────────────────────────────

  group('AddressEntry', () {
    test('fullAddressTh formats correctly', () {
      final entry = _buildTestEntries()[0];
      expect(
        entry.fullAddressTh,
        'พระบรมมหาราชวัง • พระนคร • กรุงเทพมหานคร • 10200',
      );
    });

    test('fullAddressEn formats correctly', () {
      final entry = _buildTestEntries()[0];
      expect(
        entry.fullAddressEn,
        'Phra Borom Maha Ratchawang • Phra Nakhon • Bangkok • 10200',
      );
    });

    test('searchText is lowercased and contains all fields', () {
      final entry = _buildTestEntries()[0];
      final text = entry.searchText;
      expect(text, contains('พระบรมมหาราชวัง'));
      expect(text, contains('phra borom maha ratchawang'));
      expect(text, contains('กรุงเทพมหานคร'));
      expect(text, contains('bangkok'));
      expect(text, contains('10200'));
    });

    test('searchText is lazily cached (same reference)', () {
      final entry = _buildTestEntries()[0];
      final text1 = entry.searchText;
      final text2 = entry.searchText;
      expect(identical(text1, text2), isTrue);
    });

    test('equality based on subDistrictId', () {
      final entries = _buildTestEntries();
      final entry1 = entries[0];
      final entry1Copy = AddressEntry(
        index: 99,
        provinceId: 999,
        districtId: 999,
        subDistrictId: 100101, // Same subDistrictId
        provinceTh: 'X',
        provinceEn: 'X',
        districtTh: 'X',
        districtEn: 'X',
        subDistrictTh: 'X',
        subDistrictEn: 'X',
        zipCode: '00000',
      );
      expect(entry1, equals(entry1Copy));
      expect(entry1.hashCode, entry1Copy.hashCode);
      expect(entry1 == entries[1], isFalse);
    });

    test('nullable lat/lng', () {
      final entries = _buildTestEntries();
      expect(entries[0].lat, 13.751);
      expect(entries[0].lng, 100.492);
      expect(entries[1].lat, isNull);
      expect(entries[1].lng, isNull);
    });

    test('toString returns meaningful string', () {
      final entry = _buildTestEntries()[0];
      expect(entry.toString(), contains('AddressEntry'));
      expect(entry.toString(), contains('พระบรมมหาราชวัง'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // VillageEntry Model
  // ─────────────────────────────────────────────────────────────────────────

  group('VillageEntry', () {
    test('displayName includes mooNo when > 0', () {
      const v = VillageEntry(
        id: 1,
        nameTh: 'บ้านทุ่ง',
        mooNo: 3,
        subDistrictId: 1,
      );
      expect(v.displayName, 'บ้านทุ่ง หมู่ 3');
    });

    test('displayName excludes mooNo when 0', () {
      const v = VillageEntry(
        id: 2,
        nameTh: 'บ้านท่าน้ำ',
        mooNo: 0,
        subDistrictId: 1,
      );
      expect(v.displayName, 'บ้านท่าน้ำ');
    });

    test('equality based on id', () {
      const v1 = VillageEntry(id: 1, nameTh: 'A', mooNo: 1, subDistrictId: 1);
      const v2 = VillageEntry(id: 1, nameTh: 'B', mooNo: 2, subDistrictId: 2);
      const v3 = VillageEntry(id: 2, nameTh: 'A', mooNo: 1, subDistrictId: 1);
      expect(v1, equals(v2));
      expect(v1 == v3, isFalse);
    });

    test('toString', () {
      const v = VillageEntry(
        id: 1,
        nameTh: 'บ้านทุ่ง',
        mooNo: 3,
        subDistrictId: 100,
      );
      expect(v.toString(), contains('VillageEntry'));
      expect(v.toString(), contains('บ้านทุ่ง'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SearchResult Model
  // ─────────────────────────────────────────────────────────────────────────

  group('AddressSearchResult', () {
    test('toString includes score and address', () {
      final entry = _buildTestEntries()[0];
      final result = AddressSearchResult(entry: entry, score: 100);
      expect(result.toString(), contains('100.0'));
      expect(result.toString(), contains('พระบรมมหาราชวัง'));
    });
  });

  group('VillageSearchResult', () {
    test('displayText includes full address chain', () {
      final villages = _buildTestVillages();
      final entries = _buildTestEntries();
      final result = VillageSearchResult(
        village: villages[0],
        parentAddress: entries[0],
        score: 100,
      );
      expect(result.displayText, contains('บ้านทุ่งนา'));
      expect(result.displayText, contains('พระบรมมหาราชวัง'));
      expect(result.displayText, contains('กรุงเทพมหานคร'));
    });

    test('displayText without parent', () {
      final village = _buildTestVillages()[0];
      final result = VillageSearchResult(village: village, score: 50);
      expect(result.displayText, 'บ้านทุ่งนา หมู่ 3');
    });
  });

  group('TextHighlight', () {
    test('toString', () {
      const h = TextHighlight(field: 'subDistrictTh', start: 4, end: 9);
      expect(h.toString(), 'TextHighlight(subDistrictTh[4:9])');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TrigramIndex
  // ─────────────────────────────────────────────────────────────────────────

  group('TrigramIndex', () {
    late TrigramIndex index;

    setUp(() => index = TrigramIndex());

    test('extractTrigrams produces correct trigrams', () {
      expect(TrigramIndex.extractTrigrams('abcde'), ['abc', 'bcd', 'cde']);
    });

    test('extractTrigrams for Thai text', () {
      final trigrams = TrigramIndex.extractTrigrams('กรุงเทพ');
      // กรุงเทพ = 7 chars (ก,ร,ุ,ง,เ,ท,พ) → 5 trigrams
      expect(trigrams, ['กรุ', 'รุง', 'ุงเ', 'งเท', 'เทพ']);
    });

    test('extractTrigrams returns empty for short text', () {
      expect(TrigramIndex.extractTrigrams('ab'), isEmpty);
      expect(TrigramIndex.extractTrigrams('a'), isEmpty);
      expect(TrigramIndex.extractTrigrams(''), isEmpty);
    });

    test('addDocument and query basic', () {
      index.addDocument(0, ['hello world']);
      index.addDocument(1, ['hello dart']);
      index.addDocument(2, ['world peace']);

      final helloResults = index.query('hello');
      expect(helloResults, containsAll([0, 1]));
      expect(helloResults.contains(2), isFalse);
    });

    test('query with Thai text', () {
      index.addDocument(0, ['กรุงเทพมหานคร']);
      index.addDocument(1, ['เชียงใหม่']);
      index.addDocument(2, ['กรุงเก่า']);

      final results = index.query('กรุง');
      expect(results, containsAll([0, 2]));
      expect(results.contains(1), isFalse);
    });

    test('query with no results', () {
      index.addDocument(0, ['hello']);
      expect(index.query('xyz'), isEmpty);
    });

    test('short query fallback (1-2 chars)', () {
      index.addDocument(0, ['abc']);
      index.addDocument(1, ['abd']);
      index.addDocument(2, ['xyz']);

      // 'ab' should match docs containing trigrams that include 'ab'
      final results = index.query('ab');
      expect(results, containsAll([0, 1]));
    });

    test('documentCount and trigramCount', () {
      expect(index.documentCount, 0);
      expect(index.trigramCount, 0);

      index.addDocument(0, ['hello']);
      expect(index.documentCount, 1);
      expect(index.trigramCount, greaterThan(0));
    });

    test('clear resets everything', () {
      index.addDocument(0, ['hello']);
      index.clear();
      expect(index.documentCount, 0);
      expect(index.trigramCount, 0);
      expect(index.query('hello'), isEmpty);
    });

    test('multiple fields per document', () {
      index.addDocument(0, ['hello', 'world']);
      expect(index.query('hello'), contains(0));
      expect(index.query('world'), contains(0));
    });

    test('empty field is skipped', () {
      index.addDocument(0, ['', 'hello']);
      expect(index.query('hello'), contains(0));
    });

    test('query empty string returns empty', () {
      index.addDocument(0, ['hello']);
      expect(index.query(''), isEmpty);
      expect(index.query('   '), isEmpty);
    });

    test('bigram indexing for 2-char fields', () {
      index.addDocument(0, ['กท']); // 2-char field
      // Should be findable via short-term fallback
      final results = index.query('กท');
      expect(results, contains(0));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // QueryParser
  // ─────────────────────────────────────────────────────────────────────────

  group('QueryParser', () {
    test('empty input returns ParsedQuery.empty', () {
      final q = QueryParser.parse('');
      expect(q.isEmpty, isTrue);
      expect(q.terms, isEmpty);
    });

    test('whitespace-only input returns empty', () {
      final q = QueryParser.parse('   ');
      expect(q.isEmpty, isTrue);
    });

    test('single Thai term', () {
      final q = QueryParser.parse('บางนา');
      expect(q.textTerms, ['บางนา']);
      expect(q.zipTerms, isEmpty);
      expect(q.isNotEmpty, isTrue);
      expect(q.hasTextTerms, isTrue);
      expect(q.hasZipTerms, isFalse);
    });

    test('single zip term', () {
      final q = QueryParser.parse('10260');
      expect(q.zipTerms, ['10260']);
      expect(q.textTerms, isEmpty);
      expect(q.hasZipTerms, isTrue);
    });

    test('mixed text and zip', () {
      final q = QueryParser.parse('บางนา 10260');
      expect(q.textTerms, ['บางนา']);
      expect(q.zipTerms, ['10260']);
      expect(q.terms, ['บางนา', '10260']);
    });

    test('multiple text terms', () {
      final q = QueryParser.parse('Bang Na');
      expect(q.textTerms, ['Bang', 'Na']);
      expect(q.zipTerms, isEmpty);
    });

    test('partial zip (1-5 digits)', () {
      expect(QueryParser.parse('1').zipTerms, ['1']);
      expect(QueryParser.parse('10').zipTerms, ['10']);
      expect(QueryParser.parse('102').zipTerms, ['102']);
      expect(QueryParser.parse('1026').zipTerms, ['1026']);
      expect(QueryParser.parse('10260').zipTerms, ['10260']);
    });

    test('6+ digits treated as text (not a valid zip)', () {
      final q = QueryParser.parse('123456');
      expect(q.textTerms, ['123456']);
      expect(q.zipTerms, isEmpty);
    });

    test('leading/trailing whitespace is trimmed', () {
      final q = QueryParser.parse('  บางนา  10  ');
      expect(q.raw, 'บางนา  10');
      expect(q.terms, ['บางนา', '10']);
    });

    test('ParsedQuery.empty is usable', () {
      expect(ParsedQuery.empty.isEmpty, isTrue);
      expect(ParsedQuery.empty.terms, isEmpty);
    });

    test('toString', () {
      final q = QueryParser.parse('บางนา 10');
      expect(q.toString(), contains('text:'));
      expect(q.toString(), contains('zip:'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // LruCache
  // ─────────────────────────────────────────────────────────────────────────

  group('LruCache', () {
    test('put and get', () {
      final cache = LruCache<String, int>(maxSize: 3);
      cache.put('a', 1);
      expect(cache.get('a'), 1);
      expect(cache.length, 1);
    });

    test('get returns null for missing key', () {
      final cache = LruCache<String, int>();
      expect(cache.get('missing'), isNull);
    });

    test('evicts LRU entry when exceeding maxSize', () {
      final cache = LruCache<String, int>(maxSize: 2);
      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3); // 'a' should be evicted
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), 2);
      expect(cache.get('c'), 3);
      expect(cache.length, 2);
    });

    test('get promotes entry to most-recently-used', () {
      final cache = LruCache<String, int>(maxSize: 2);
      cache.put('a', 1);
      cache.put('b', 2);
      cache.get('a'); // Promote 'a' — now 'b' is LRU
      cache.put('c', 3); // 'b' should be evicted
      expect(cache.get('a'), 1);
      expect(cache.get('b'), isNull);
      expect(cache.get('c'), 3);
    });

    test('put updates existing key', () {
      final cache = LruCache<String, int>(maxSize: 3);
      cache.put('a', 1);
      cache.put('a', 10);
      expect(cache.get('a'), 10);
      expect(cache.length, 1);
    });

    test('clear empties the cache', () {
      final cache = LruCache<String, int>(maxSize: 3);
      cache.put('a', 1);
      cache.put('b', 2);
      cache.clear();
      expect(cache.isEmpty, isTrue);
      expect(cache.length, 0);
    });

    test('remove returns value', () {
      final cache = LruCache<String, int>();
      cache.put('a', 1);
      expect(cache.remove('a'), 1);
      expect(cache.get('a'), isNull);
    });

    test('remove returns null for missing key', () {
      final cache = LruCache<String, int>();
      expect(cache.remove('x'), isNull);
    });

    test('containsKey', () {
      final cache = LruCache<String, int>();
      cache.put('a', 1);
      expect(cache.containsKey('a'), isTrue);
      expect(cache.containsKey('b'), isFalse);
    });

    test('isFull', () {
      final cache = LruCache<String, int>(maxSize: 2);
      expect(cache.isFull, isFalse);
      cache.put('a', 1);
      expect(cache.isFull, isFalse);
      cache.put('b', 2);
      expect(cache.isFull, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // ThaiAddressSearchEngine
  // ─────────────────────────────────────────────────────────────────────────

  group('ThaiAddressSearchEngine', () {
    late ThaiAddressSearchEngine engine;
    late List<AddressEntry> entries;

    setUp(() {
      engine = ThaiAddressSearchEngine(cacheSize: 32);
      entries = _buildTestEntries();
      engine.buildIndex(entries);
    });

    tearDown(() => engine.dispose());

    test('isReady after buildIndex', () {
      expect(engine.isReady, isTrue);
      expect(engine.entryCount, entries.length);
      expect(engine.trigramCount, greaterThan(0));
    });

    test('search throws when not initialized', () {
      final freshEngine = ThaiAddressSearchEngine();
      expect(
        () => freshEngine.search('test'),
        throwsA(isA<AddressSearchException>()),
      );
    });

    test('search empty query returns empty', () {
      expect(engine.search(''), isEmpty);
      expect(engine.search('   '), isEmpty);
    });

    // ── Thai text matching ──

    test('search Thai sub-district name', () {
      final results = engine.search('บางนา');
      expect(results, isNotEmpty);
      expect(results.any((r) => r.entry.subDistrictTh == 'บางนา'), isTrue);
    });

    test('search Thai district name', () {
      final results = engine.search('พระนคร');
      expect(results, isNotEmpty);
      expect(results.every((r) => r.entry.districtTh == 'พระนคร'), isTrue);
    });

    test('search Thai province name', () {
      final results = engine.search('กรุงเทพ');
      expect(results, isNotEmpty);
      for (final r in results) {
        expect(r.entry.provinceTh, contains('กรุงเทพ'));
      }
    });

    // ── English text matching ──

    test('search English name', () {
      final results = engine.search('Bangkok');
      expect(results, isNotEmpty);
      for (final r in results) {
        expect(r.entry.provinceEn, 'Bangkok');
      }
    });

    test('search English partial', () {
      final results = engine.search('Phra');
      expect(results, isNotEmpty);
    });

    // ── Zip code matching ──

    test('search exact zip code', () {
      final results = engine.search('10260');
      expect(results, isNotEmpty);
      expect(results.first.entry.zipCode, '10260');
      expect(results.first.score, greaterThanOrEqualTo(100));
    });

    test('search zip prefix', () {
      final results = engine.search('102');
      expect(results, isNotEmpty);
      for (final r in results) {
        expect(r.entry.zipCode.startsWith('102'), isTrue);
      }
    });

    test('search broad zip prefix returns multiple', () {
      final results = engine.search('10');
      expect(results.length, greaterThanOrEqualTo(2));
    });

    // ── Multi-term search ──

    test('multi-term AND logic: text + zip', () {
      final results = engine.search('บางนา 10');
      expect(results, isNotEmpty);
      for (final r in results) {
        expect(r.entry.zipCode.startsWith('10'), isTrue);
        expect(r.entry.searchText.contains('บางนา'), isTrue);
      }
    });

    test('multi-term AND logic: two text terms', () {
      final results = engine.search('Phra Nakhon');
      expect(results, isNotEmpty);
      for (final r in results) {
        expect(r.entry.districtEn, 'Phra Nakhon');
      }
    });

    test('multi-term no intersection returns empty', () {
      final results = engine.search('บางนา 50200');
      expect(results, isEmpty);
    });

    // ── Scoring ──

    test('exact match scores higher than prefix match', () {
      final results = engine.search('บางนา');
      expect(results, isNotEmpty);

      final exactMatch = results.where(
        (r) =>
            r.entry.subDistrictTh == 'บางนา' || r.entry.districtTh == 'บางนา',
      );
      if (exactMatch.isNotEmpty) {
        final containsMatch = results.where(
          (r) =>
              r.entry.subDistrictTh != 'บางนา' && r.entry.districtTh != 'บางนา',
        );
        if (containsMatch.isNotEmpty) {
          expect(
            exactMatch.first.score,
            greaterThan(containsMatch.first.score),
          );
        }
      }
    });

    test('results sorted by score descending', () {
      final results = engine.search('กรุงเทพ');
      for (var i = 1; i < results.length; i++) {
        expect(results[i].score, lessThanOrEqualTo(results[i - 1].score));
      }
    });

    // ── maxResults ──

    test('maxResults limits output', () {
      final results = engine.search('กรุงเทพ', maxResults: 2);
      expect(results.length, lessThanOrEqualTo(2));
    });

    // ── Caching ──

    test('repeated search hits cache', () {
      final results1 = engine.search('บางนา');
      final results2 = engine.search('บางนา');
      // Same reference from cache
      expect(identical(results1, results2), isTrue);
    });

    test('clearCache forces re-computation', () {
      final results1 = engine.search('บางนา');
      engine.clearCache();
      final results2 = engine.search('บางนา');
      // Different object but same content
      expect(identical(results1, results2), isFalse);
      expect(results1.length, results2.length);
    });

    // ── Rebuild ──

    test('buildIndex again replaces index and clears cache', () {
      engine.search('test'); // Populate cache
      engine.buildIndex(entries.sublist(0, 2));
      expect(engine.entryCount, 2);
    });

    // ── Dispose ──

    test('dispose makes engine not ready', () {
      engine.dispose();
      expect(engine.isReady, isFalse);
      expect(engine.entryCount, 0);
    });

    // ── Village Search ──

    group('Village Search', () {
      test('searchVillages throws when index not built', () {
        expect(
          () => engine.searchVillages('บ้าน'),
          throwsA(isA<AddressSearchException>()),
        );
      });

      test('searchVillages returns results after buildVillageIndex', () {
        engine.buildVillageIndex(_buildTestVillages());
        expect(engine.isVillageIndexReady, isTrue);

        final results = engine.searchVillages('บ้านทุ่ง');
        expect(results, isNotEmpty);
        expect(results.any((r) => r.village.nameTh.contains('ทุ่ง')), isTrue);
      });

      test('searchVillages returns empty for no match', () {
        engine.buildVillageIndex(_buildTestVillages());
        final results = engine.searchVillages('ไม่มีหมู่บ้านนี้');
        expect(results, isEmpty);
      });

      test('searchVillages empty query returns empty', () {
        engine.buildVillageIndex(_buildTestVillages());
        expect(engine.searchVillages(''), isEmpty);
      });

      test('village results include parent address context', () {
        engine.buildVillageIndex(_buildTestVillages());
        final results = engine.searchVillages('คลองลาด');
        expect(results, isNotEmpty);
        final r = results.first;
        expect(r.parentAddress, isNotNull);
        expect(r.parentAddress?.districtTh, 'บางนา');
      });

      test('village results sorted by score', () {
        engine.buildVillageIndex(_buildTestVillages());
        final results = engine.searchVillages('บ้าน');
        for (var i = 1; i < results.length; i++) {
          expect(results[i].score, lessThanOrEqualTo(results[i - 1].score));
        }
      });

      test('village maxResults', () {
        engine.buildVillageIndex(_buildTestVillages());
        final results = engine.searchVillages('บ้าน', maxResults: 2);
        expect(results.length, lessThanOrEqualTo(2));
      });
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Integration: Real-World Scenarios
  // ─────────────────────────────────────────────────────────────────────────

  group('Integration Scenarios', () {
    late ThaiAddressSearchEngine engine;

    setUp(() {
      engine = ThaiAddressSearchEngine();
      engine.buildIndex(_buildTestEntries());
    });

    tearDown(() => engine.dispose());

    test('Scenario: User types partial zip then adds district', () {
      // Step 1: type "10"
      var results = engine.search('10');
      expect(results, isNotEmpty);

      // Step 2: refine with text
      results = engine.search('10 บางนา');
      expect(results, isNotEmpty);
      expect(results.first.entry.districtTh, 'บางนา');
    });

    test('Scenario: Search by English city name', () {
      final results = engine.search('Chiang Mai');
      expect(results, isNotEmpty);
      expect(results.first.entry.provinceEn, 'Chiang Mai');
    });

    test('Scenario: Search Phuket by zip', () {
      final results = engine.search('83000');
      expect(results, isNotEmpty);
      expect(results.first.entry.provinceTh, 'ภูเก็ต');
    });

    test('Scenario: No results for gibberish', () {
      final results = engine.search('xyzxyzxyz');
      expect(results, isEmpty);
    });

    test('Scenario: Single character search', () {
      // Should not crash, may return broad results
      final results = engine.search('บ');
      // Just verify it doesn't throw
      expect(results, isA<List<AddressSearchResult>>());
    });
  });
}
