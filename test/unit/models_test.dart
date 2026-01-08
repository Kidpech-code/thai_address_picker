import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/models/district.dart';
import 'package:thai_address_picker/src/models/geography.dart';
import 'package:thai_address_picker/src/models/province.dart';
import 'package:thai_address_picker/src/models/sub_district.dart';
import 'package:thai_address_picker/src/models/village.dart';
import 'package:thai_address_picker/src/models/thai_address.dart';

void main() {
  group('Models Serialization Tests', () {
    test('Geography fromJson', () {
      final json = {'id': 1, 'name': 'Northern'};
      final model = Geography.fromJson(json);
      expect(model.id, 1);
      expect(model.name, 'Northern');
    });

    test('Province fromJson', () {
      final json = {
        'id': 1,
        'name_th': 'กทม',
        'name_en': 'BKK',
        'geography_id': 2,
      };
      final model = Province.fromJson(json);
      expect(model.id, 1);
      expect(model.nameTh, 'กทม');
      expect(model.nameEn, 'BKK');
      expect(model.geographyId, 2);
    });

    test('District fromJson', () {
      final json = {
        'id': 1001,
        'name_th': 'เขตพระนคร',
        'name_en': 'Phra Nakhon',
        'province_id': 1,
      };
      final model = District.fromJson(json);
      expect(model.id, 1001);
      expect(model.nameTh, 'เขตพระนคร');
      expect(model.nameEn, 'Phra Nakhon');
      expect(model.provinceId, 1);
    });

    test('SubDistrict fromJson', () {
      final json = {
        'id': 100101,
        'zip_code': 10200, // Int case handling
        'name_th': 'พระบรมมหาราชวัง',
        'name_en': 'Phra Borom Maha Ratchawang',
        'district_id': 1001,
        'lat': 13.751,
        'long': 100.492,
      };
      final model = SubDistrict.fromJson(json);
      expect(model.id, 100101);
      expect(model.zipCode, '10200'); // Should convert to string
      expect(model.nameTh, 'พระบรมมหาราชวัง');
      expect(model.lat, 13.751);
    });

    test('SubDistrict fromJson with String zip_code', () {
      final json = {
        'id': 100101,
        'zip_code': '10200',
        'name_th': 'พระบรมมหาราชวัง',
        'name_en': 'Phra Borom Maha Ratchawang',
        'district_id': 1001,
        'lat': 13.751,
        'long': 100.492,
      };
      final model = SubDistrict.fromJson(json);
      expect(model.zipCode, '10200');
    });

    test('Village fromJson', () {
      final json = {
        'id': 11,
        'name_th': 'บ้านทุ่ง',
        'moo_no': 3,
        'sub_district_id': 100101,
        'lat': 13.5,
        'long': 100.5,
      };
      final model = Village.fromJson(json);
      expect(model.id, 11);
      expect(model.nameTh, 'บ้านทุ่ง');
      expect(model.mooNo, 3);
      expect(model.subDistrictId, 100101);
      expect(model.lat, 13.5);
    });

    test('Village fromJson with null lat/long', () {
      final json = {
        'id': 11,
        'name_th': 'บ้านทุ่ง',
        'moo_no': 3,
        'sub_district_id': 100101,
        'lat': null,
        'long': null,
      };
      final model = Village.fromJson(json);
      expect(model.lat, isNull);
      expect(model.long, isNull);
    });

    test('ThaiAddress creation', () {
      final address = ThaiAddress(
        provinceTh: 'P',
        districtTh: 'D',
        subDistrictTh: 'S',
        zipCode: '10000',
      );
      expect(address.provinceTh, 'P');
      // No fullAddressTh getter currently
    });
  });
}
