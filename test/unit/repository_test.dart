import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';
import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ThaiAddressRepository initialization and filtering', () async {
    final repo = ThaiAddressRepository();

    // We can't easily "reset" the singleton _instance or _isInitialized flag
    // because they are private.
    // This is a common issue with Singleton testing.
    // If previous tests ran, this might just return immediately.
    // Ideally we put this validation in the main test flow.

    // Assuming this test file works in isolation or first.
    await repo.initialize(bundle: FakeAssetBundle(), useIsolate: false);

    // Verify Geographies
    expect(repo.geographies.length, 1);
    expect(repo.getGeographyById(1)?.name, 'Geo1');

    // Verify Provinces
    expect(repo.provinces.length, 1);
    expect(repo.getProvincesByGeography(1).first.nameTh, 'P1');
    expect(repo.getProvinceById(1)?.nameEn, 'P1_EN');

    // Verify Districts
    expect(repo.districts.length, 1);
    expect(repo.getDistrictsByProvince(1).first.nameTh, 'D1');

    // Verify SubDistricts
    expect(repo.subDistricts.length, 4);
    expect(repo.getSubDistrictsByDistrict(1001).length, 4);
    expect(repo.villages.length, 2);
    expect(repo.getVillagesBySubDistrict(100101).length, 2);
    expect(repo.getVillagesBySubDistrict(100101).first.nameTh, 'บ้านทดสอบ2');

    // Check ZipCode index?
    // The zip code index is private _zipCodeIndex, but accessed via something?
    // Wait, the repository doesn't have a public getter for ZipCode index specifically,
    // usually used by widgets.
    // But check the source: `searchAddress`? No, let's look.
  });
}
