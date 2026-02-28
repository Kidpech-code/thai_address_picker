import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';
// import 'package:flutter/foundation.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThaiAddressRepository Coverage', () {
    late ThaiAddressRepository repository;

    setUp(() {
      repository = ThaiAddressRepository();
      // Ensure clean state
      repository.resetForTesting();
    });

    test('getters throw StateError when not initialized', () async {
      expect(() => repository.geographies, throwsStateError);
      expect(() => repository.provinces, throwsStateError);
      expect(() => repository.districts, throwsStateError);
      expect(() => repository.subDistricts, throwsStateError);
      // Note: villages is now lazy/async — accessed via getVillagesBySubDistrict()

      expect(() => repository.searchProvinces(''), throwsStateError);
      expect(() => repository.searchDistricts(''), throwsStateError);
      expect(() => repository.searchSubDistricts(''), throwsStateError);
      // searchVillages is async — it returns a Future that rejects when uninitialized
      expect(repository.searchVillages('test'), throwsA(isA<StateError>()));
      expect(() => repository.searchZipCodes(''), throwsStateError);

      expect(() => repository.getSubDistrictsByZipCode(''), throwsStateError);
    });

    test('initialize throws Exception on asset load failure', () async {
      final badBundle = FakeAssetBundleThatThrows();
      expect(
        () => repository.initialize(bundle: badBundle, useIsolate: false),
        throwsA(isA<Exception>()),
      );
    });

    test('initialize works with useIsolate: true', () async {
      // Re-setup repository
      repository.resetForTesting();
      // FakeAssetBundle returns valid JSON so this should work even with compute
      // provided the environment supports it.
      // In specialized test envs compute might be mocked or run synchronously,
      // but hitting the line "compute(parseJsonInIsolate, params)" is what counts.
      await repository.initialize(bundle: FakeAssetBundle(), useIsolate: true);
      expect(repository.provinces.length, 1);
    });

    test('parseJsonInIsolate throws on unknown type', () {
      final params = JsonParseParams('[]', 'unknown_type');
      expect(() => parseJsonInIsolate(params), throwsException);
    });

    test('parseJsonInIsolate handles all types correctly', () {
      const _ =
          '[{"id": 1, "name_th": "th", "name_en": "en"}]'; // Minimal valid JSON for most
      // Geography might have different fields, check model.
      // Geography: int id, String name.
      // Province: id, name_th, name_en, geography_id.
      // District: id, name_th, name_en, province_id.
      // SubDistrict: id, name_th, name_en, district_id, zip_code.
      // Village: id, name_th, name_en, sub_district_id, moo_no.

      // We can use empty list [] for safer coverage of the switch case itself, logic inside map is covered by model tests.
      expect(
        parseJsonInIsolate(JsonParseParams('[]', 'geography')),
        isA<List<Geography>>(),
      );
      expect(
        parseJsonInIsolate(JsonParseParams('[]', 'province')),
        isA<List<Province>>(),
      );
      expect(
        parseJsonInIsolate(JsonParseParams('[]', 'district')),
        isA<List<District>>(),
      );
      expect(
        parseJsonInIsolate(JsonParseParams('[]', 'subDistrict')),
        isA<List<SubDistrict>>(),
      );
      expect(
        parseJsonInIsolate(JsonParseParams('[]', 'village')),
        isA<List<Village>>(),
      );
    });

    test('search methods handle empty queries and null filters', () async {
      await repository.initialize(bundle: FakeAssetBundle(), useIsolate: false);

      // Empty query returns all/filtered list
      expect(repository.searchProvinces('').length, isPositive);
      expect(repository.searchDistricts('').length, isPositive);
      expect(repository.searchSubDistricts('').length, isPositive);

      // Search with null parent (should search all)
      expect(
        repository.searchDistricts('d', provinceId: null).length,
        isPositive,
      );
      expect(
        repository.searchSubDistricts('s', districtId: null).length,
        isPositive,
      );

      // Search with filters
      final validProvinceId = repository.provinces.first.id;
      expect(
        repository.searchDistricts('d', provinceId: validProvinceId).length,
        isPositive,
      );
      // searchZipCodes maxResults
      // Should stop after 1
      final limitedResults = repository.searchZipCodes('10', maxResults: 1);
      expect(limitedResults.length, 1);

      // searchZipCodes logic with duplicates
      // We added a duplicate SD3 (id 100103) in FakeAssetBundle.
      // searchZipCodes iterates the list. It should encounter SD3, add it.
      // Then encounter SD3 Duplicate (same ID), and skip it.
      // We can verify total count.
      // 10200 (SD1), 10300 (SD2), 10300 (SD3). Max 3 unique.
      // The duplicate SD3 should be skipped.
      final allZipResults = repository.searchZipCodes('10');
      // If duplicate was NOT skipped, we would see 4 (SD1, SD2, SD3, SD3_Dup).
      // Since skipped, 3.
      // Wait, SD3 and SD3_Dup in my fake bundle had SAME ID. Key = zip + id.
      // So key is same.
      // Logic checks key.
      expect(allZipResults.length, 3);
    });
  });
}

class FakeAssetBundleThatThrows extends FakeAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    throw Exception('Asset load failed');
  }
}
