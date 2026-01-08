import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/models/district.dart';
import 'package:thai_address_picker/src/models/province.dart';
import 'package:thai_address_picker/src/models/sub_district.dart';
import 'package:thai_address_picker/src/providers/thai_address_providers.dart';
import 'package:thai_address_picker/src/repository/thai_address_repository.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;

  final repository = ThaiAddressRepository();
  final fakeBundle = FakeAssetBundle();

  setUpAll(() async {
    // Initialize repository with fake data
    await repository.initialize(bundle: fakeBundle, useIsolate: false);
  });

  setUp(() {
    container = ProviderContainer(
      overrides: [thaiAddressRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ThaiAddressNotifier', () {
    test('initial state is correct', () {
      final state = container.read(thaiAddressNotifierProvider);
      expect(state.selectedProvince, null);
      expect(state.selectedDistrict, null);
      expect(state.selectedSubDistrict, null);
      expect(state.zipCode, null);
    });

    test('selectProvince updates state and clears downstream', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      final province = repository.provinces.first;

      notifier.selectProvince(province);
      expect(
        container.read(thaiAddressNotifierProvider).selectedProvince,
        province,
      );

      // Simulate deeper selection
      notifier.selectDistrict(repository.districts.first);
      expect(
        container.read(thaiAddressNotifierProvider).selectedDistrict,
        isNotNull,
      );

      // Selecting province again should clear district/sub/zip
      notifier.selectProvince(repository.provinces.last);
      final state = container.read(thaiAddressNotifierProvider);
      expect(state.selectedProvince, repository.provinces.last);
      expect(state.selectedDistrict, null);
      expect(state.selectedSubDistrict, null);
      expect(state.zipCode, null);
    });

    test('selectDistrict updates state and clears downstream', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      final province = repository.provinces.first;
      notifier.selectProvince(province);

      final district = repository.districts
          .where((d) => d.provinceId == province.id)
          .first;
      notifier.selectDistrict(district);

      expect(
        container.read(thaiAddressNotifierProvider).selectedDistrict,
        district,
      );

      // Verify district clears sub/zip
      // Set SubDistrict first
      final subDistrict = repository.subDistricts
          .where((s) => s.districtId == district.id)
          .first;
      notifier.selectSubDistrict(subDistrict);
      expect(
        container.read(thaiAddressNotifierProvider).selectedSubDistrict,
        subDistrict,
      );

      // Change District
      final anotherDistrict = repository.districts
          .where((d) => d.provinceId == province.id)
          .last;
      notifier.selectDistrict(anotherDistrict);

      final state = container.read(thaiAddressNotifierProvider);
      expect(state.selectedDistrict, anotherDistrict);
      expect(state.selectedSubDistrict, null);
      expect(state.zipCode, null);
    });

    test('selectSubDistrict updates state and sets zip code', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      final subDistrict = repository.subDistricts.first;

      notifier.selectSubDistrict(subDistrict);
      final state = container.read(thaiAddressNotifierProvider);
      expect(state.selectedSubDistrict, subDistrict);
      // Repository data for first subDistrict (100101) has zip 10200
      expect(state.zipCode, '10200');
    });

    test('reset clears everything', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      notifier.selectProvince(repository.provinces.first);
      notifier.reset();

      final state = container.read(thaiAddressNotifierProvider);
      expect(state.selectedProvince, null);
      expect(state.selectedDistrict, null);
    });

    // setZipCode tests
    test('setZipCode empty clears all', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      notifier.selectProvince(repository.provinces.first);
      notifier.setZipCode('');

      final state = container.read(thaiAddressNotifierProvider);
      expect(state.selectedProvince, null);
      expect(state.zipCode, null);
      expect(state.error, null);
    });

    test('setZipCode partial (<5) sets zip only', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      notifier.setZipCode('102');

      final state = container.read(thaiAddressNotifierProvider);
      expect(state.zipCode, '102');
      expect(state.selectedProvince, null);
      expect(state.error, null);
    });

    test('setZipCode not found error', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      notifier.setZipCode('99999');

      final state = container.read(thaiAddressNotifierProvider);
      expect(state.zipCode, '99999');
      expect(state.error, isNotNull);
    });

    test('setZipCode single match auto-fills', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      // 10200 is unique in fake bundle (ID 100101)
      notifier.setZipCode('10200');

      final state = container.read(thaiAddressNotifierProvider);
      expect(state.zipCode, '10200');
      expect(state.error, null);
      expect(state.selectedSubDistrict, isNotNull);
      expect(state.selectedSubDistrict!.id, 100101);
      expect(state.selectedDistrict, isNotNull);
      expect(state.selectedProvince, isNotNull);
    });

    test('setZipCode multiple matches only sets zip', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      // 10300 is duplicate (ID 100102 and 100103)
      notifier.setZipCode('10300');

      final state = container.read(thaiAddressNotifierProvider);
      expect(state.zipCode, '10300');
      expect(state.error, null);
      expect(state.selectedSubDistrict, null); // Ambiguous result
      expect(state.selectedDistrict, null);
      expect(state.selectedProvince, null);
    });

    test('selectZipCodeSuggestion fills from suggestion', () {
      // Just mock a suggestion object
      final p = repository.provinces.first;
      final d = repository.districts.first;
      final s = repository.subDistricts.first;
      final suggestion = ZipCodeSuggestion(
        zipCode: '10200',
        subDistrict: s,
        district: d,
        province: p,
      );

      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      notifier.selectZipCodeSuggestion(suggestion);

      final state = container.read(thaiAddressNotifierProvider);
      expect(state.selectedProvince, p);
      expect(state.selectedSubDistrict, s);
    });

    test('available providers filter correctly', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);
      // Initially empty
      expect(container.read(availableDistrictsProvider), isEmpty);

      // Select Province 1
      notifier.selectProvince(repository.provinces.first);
      // Should have District 1 (ID 1001)
      expect(container.read(availableDistrictsProvider).first.id, 1001);

      // Select District 1
      notifier.selectDistrict(repository.districts.first);
      // Should have SubDistricts (100101, 100102, 100103, 100103_Dup) (4 total)
      expect(container.read(availableSubDistrictsProvider).length, 4);

      // Clear district
      notifier.selectDistrict(null);
      expect(container.read(availableSubDistrictsProvider), isEmpty);
    });

    test('search methods delegate to repository', () {
      final notifier = container.read(thaiAddressNotifierProvider.notifier);

      expect(notifier.searchProvinces('P'), isNotEmpty);
      expect(
        notifier.searchDistricts('D'),
        isNotEmpty,
      ); // Search all because province not selected?

      notifier.selectProvince(repository.provinces.first);
      expect(notifier.searchDistricts('D'), isNotEmpty); // Scoped search

      notifier.selectDistrict(repository.districts.first);
      expect(notifier.searchSubDistricts('S'), isNotEmpty);

      expect(notifier.searchZipCodes('10'), isNotEmpty);
    });
  });

  group('ThaiAddressState', () {
    test('copyWith works correctly', () {
      final state = ThaiAddressState();
      final p = Province(id: 1, nameEn: 'A', nameTh: 'ก', geographyId: 1);

      final s1 = state.copyWith(selectedProvince: p);
      expect(s1.selectedProvince, p);

      final s2 = s1.copyWith(clearProvince: true);
      expect(s2.selectedProvince, null);
    });

    test('toThaiAddress mappings', () {
      final p = Province(id: 1, nameEn: 'P_En', nameTh: 'P_Th', geographyId: 1);
      final d = District(
        id: 101,
        nameEn: 'D_En',
        nameTh: 'D_Th',
        provinceId: 1,
      );
      final s = SubDistrict(
        id: 1001,
        nameEn: 'S_En',
        nameTh: 'S_Th',
        districtId: 101,
        zipCode: '12345',
        lat: null,
        long: null,
      );

      final state = ThaiAddressState(
        selectedProvince: p,
        selectedDistrict: d,
        selectedSubDistrict: s,
        zipCode: '12345',
      );

      final address = state.toThaiAddress();
      expect(address.provinceTh, 'P_Th');
      expect(address.provinceEn, 'P_En');
      expect(address.districtTh, 'D_Th');
      expect(address.subDistrictTh, 'S_Th');
      expect(address.zipCode, '12345');
    });
  });
}
