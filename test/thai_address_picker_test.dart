import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

void main() {
  group('ThaiAddressRepository', () {
    test('should be a singleton', () {
      final repo1 = ThaiAddressRepository();
      final repo2 = ThaiAddressRepository();
      expect(repo1, equals(repo2));
    });
  });

  group('ThaiAddress Model', () {
    test('should create Thai address with all fields', () {
      final address = ThaiAddress(
        provinceTh: 'กรุงเทพมหานคร',
        provinceEn: 'Bangkok',
        provinceId: 1,
        districtTh: 'พระนคร',
        districtEn: 'Phra Nakhon',
        districtId: 1001,
        subDistrictTh: 'พระบรมมหาราชวัง',
        subDistrictEn: 'Phra Borom Maha Ratchawang',
        subDistrictId: 100101,
        zipCode: '10200',
        lat: 13.7563,
        long: 100.4935,
      );

      expect(address.provinceTh, equals('กรุงเทพมหานคร'));
      expect(address.zipCode, equals('10200'));
      expect(address.lat, equals(13.7563));
    });

    test('should create Thai address with nullable fields', () {
      final address = ThaiAddress();

      expect(address.provinceTh, isNull);
      expect(address.zipCode, isNull);
    });
  });
}
