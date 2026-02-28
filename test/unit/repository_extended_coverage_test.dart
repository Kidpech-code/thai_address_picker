import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/repository/thai_address_repository.dart';
import '../helpers/fake_asset_bundle.dart';

class LargeFakeAssetBundle extends FakeAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.endsWith('/sub_districts.json')) {
      // Create many subdistricts to test maxResults and duplicates
      // Base ID 100100
      final List<Map<String, dynamic>> list = [];
      for (int i = 0; i < 30; i++) {
        list.add({
          'id': 100100 + i,
          'zip_code': 10200 + (i % 2), // Flip between 10200 and 10201
          'name_th': 'SD$i',
          'name_en': 'SD_EN$i',
          'district_id': 1001,
          'lat': 10.0,
          'long': 100.0,
        });
      }

      // Add duplicate SubDistrict ID to test zip code deduplication
      list.add({
        'id': 100100, // Duplicate ID
        'zip_code': 10200,
        'name_th': 'SD Duplicate',
        'name_en': 'SD_EN_Dup',
        'district_id': 1001,
        'lat': 10.0,
        'long': 100.0,
      });

      return jsonEncode(list);
    } else if (key.endsWith('/villages.json')) {
      final List<Map<String, dynamic>> list = [];
      for (int i = 0; i < 30; i++) {
        list.add({
          'id': i,
          'name_th': 'Village$i',
          'moo_no': i,
          'sub_district_id': 100100,
          'lat': 10.0,
          'long': 100.0,
        });
      }
      // Add a duplicate ID (0) to test de-duplication logic
      list.add({
        'id': 0, // Duplicate ID
        'name_th': 'Village0 Duplicate',
        'moo_no': 99,
        'sub_district_id': 100100,
        'lat': 10.0,
        'long': 100.0,
      });

      // Add broken link village (Invalid SubDistrict)
      list.add({
        'id': 777,
        'name_th': 'VillageBroken',
        'moo_no': 5,
        'sub_district_id': 99999, // Invalid
        'lat': 10.0,
        'long': 100.0,
      });

      return jsonEncode(list);
    }
    return super.loadString(key, cache: cache);
  }
}

void main() {
  group('ThaiAddressRepository Extended Coverage', () {
    late ThaiAddressRepository repository;

    setUp(() async {
      repository = ThaiAddressRepository();
      repository.resetForTesting();
      await repository.initialize(bundle: FakeAssetBundle(), useIsolate: false);
    });

    test('searchVillages validation', () async {
      expect(await repository.searchVillages(''), isEmpty);

      // Should match 'บ้าน'
      final results = await repository.searchVillages('บ้าน');
      expect(results.length, 2);
      // Logic sorts by nameTh
      expect(
        results.first.village.nameTh,
        'บ้านทดสอบ',
      ); // "บ้านทดสอบ" < "บ้านทดสอบ2"

      // Check maxResults
      final limited = await repository.searchVillages('บ้าน', maxResults: 1);
      expect(limited.length, 1);
    });

    test('searchVillages with large data triggers duplicates and limit', () async {
      repository.resetForTesting();
      await repository.initialize(
        bundle: LargeFakeAssetBundle(),
        useIsolate: false,
      );

      // We have distinct villages Village0..Village29 (30 items)
      // PLUS Village0 (duplicate name) -> Should be skipped in searchVillages loop "containsKey check"
      // Total unique names: 30.

      final _ = repository.searchVillages('Village');
      // If maxResults=20 (default), duplicates check happens first?

      // Logic: Loop all villages.
      // Village0 -> Add.
      // Village1 -> Add.
      // ...
      // Village0 (Duplicate, id 999) -> Skip?

      // Wait, duplicate check uses key: String key = '${village.id}';
      // My repo logic uses ID as key?
      // Let's check logic:
      // final key = '${village.id}';
      // if (suggestions.containsKey(key)) continue;

      // If I want to test duplicate NAME suppression, I need separate logic?
      // No, Repo seems to key by ID.
      // So duplicate ID is filtered?
      // My LargeFakeAssetBundle uses distinct IDs (0..29, then 999).
      // So ID 999 Village0 is NOT filtered by ID.

      // Wait, is there name deduplication?
      // "HashMap-based deduplication for unique entries"
      // Looking at logic:
      // if (village.nameTh ... contains ...)
      //   final key = '${village.id}';
      //   ...
      //   suggestions[key] = ...

      // So it dedupes by VILLAGE ID.
      // If multiple villages have same name but different ID, they are BOTH returned.

      // If `_villages` list contains SAME village object twice, it would be skipped.

      // OK, to hit "containsKey" check, I need same ID appearing twice in `_villages` list.
      // In LargeFakeAssetBundle, I only added distinct IDs?
      // I should add SAME ID twice in LargeFakeAssetBundle.

      // Let's update test logic inline? No, FakeAssetBundle is a class.
      // I'll update the LargeFakeAssetBundle definition later if needed.

      // But maxResults limit:
      // query 'Village' matches all 30.
      expect(
        (await repository.searchVillages('Village', maxResults: 5)).length,
        5,
      );
      expect(
        (await repository.searchVillages('Village', maxResults: 40)).length,
        31,
      ); // 31 unique IDs
    });

    test('searchZipCodes large data validation', () async {
      repository.resetForTesting();
      await repository.initialize(
        bundle: LargeFakeAssetBundle(),
        useIsolate: false,
      );

      // LargeFakeAssetBundle has 30 subDistricts.
      // Zip codes 10200, 10201.
      // 15 of each.
      // Key = '${subDistrict.zipCode}_${subDistrict.id}';
      // All IDs 100100..100129 are unique.
      // So no deduplication unless we have same ID.

      final results = repository.searchZipCodes('102');
      expect(results.length, 20); // Default maxResults

      final full = repository.searchZipCodes('102', maxResults: 100);
      expect(full.length, 30);
    });

    test('getVillagesBySubDistrict returns sorted list by mooNo', () async {
      final villages = await repository.getVillagesBySubDistrict(100101);
      expect(villages.length, 2);
      expect(villages[0].mooNo, 1); // id 2
      expect(villages[1].mooNo, 2); // id 1

      // And check empty for invalid
      expect(await repository.getVillagesBySubDistrict(999), isEmpty);
    });

    test('searchZipCodes validation', () {
      expect(repository.searchZipCodes(''), isEmpty);

      // 102
      final results = repository.searchZipCodes('102');
      expect(results.isNotEmpty, true);
      expect(results.first.zipCode, '10200');

      // Max results limit
      // We only have 2 subdistricts in FakeAssetBundle, so maxResults logic needs more data
      // or set maxResults=1
      final limited = repository.searchZipCodes('10', maxResults: 1);
      expect(limited.length, 1);
    });

    test('searchVillages handles broken data integrity gracefully', () async {
      repository.resetForTesting();
      await repository.initialize(
        bundle: LargeFakeAssetBundle(),
        useIsolate: false,
      );

      final results = await repository.searchVillages('Broken');
      expect(results.length, 1);
      expect(results.first.subDistrict, isNull);
      expect(results.first.district, isNull);
      expect(results.first.province, isNull);
    });
  });
}
