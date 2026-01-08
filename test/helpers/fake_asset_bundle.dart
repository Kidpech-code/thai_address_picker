import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAssetBundle extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.endsWith('/geographies.json')) {
      return jsonEncode([
        {'id': 1, 'name': 'Geo1'},
      ]);
    } else if (key.endsWith('/provinces.json')) {
      return jsonEncode([
        {
          'id': 1,
          'code': '10',
          'name_th': 'P1',
          'name_en': 'P1_EN',
          'geography_id': 1,
        },
      ]);
    } else if (key.endsWith('/districts.json')) {
      return jsonEncode([
        {
          'id': 1001,
          'code': '1001',
          'name_th': 'D1',
          'name_en': 'D1_EN',
          'province_id': 1,
        },
      ]);
    } else if (key.endsWith('/sub_districts.json')) {
      return jsonEncode([
        {
          'id': 100101,
          'zip_code': 10200,
          'name_th': 'SD1',
          'name_en': 'SD1_EN',
          'district_id': 1001,
          'lat': 10.0,
          'long': 100.0,
        },
        {
          'id': 100102,
          'zip_code': 10300,
          'name_th': 'SD2',
          'name_en': 'SD2_EN',
          'district_id': 1001,
          'lat': 10.0,
          'long': 100.0,
        },
        {
          'id': 100103,
          'zip_code': 10300,
          'name_th': 'SD3',
          'name_en': 'SD3_EN',
          'district_id': 1001,
          'lat': 10.0,
          'long': 100.0,
        },
        // Duplicate for testing coverage logic
        {
          'id': 100103, // Same ID as above
          'zip_code': 10300,
          'name_th': 'SD3 Duplicate',
          'name_en': 'SD3_EN',
          'district_id': 1001,
          'lat': 10.0,
          'long': 100.0,
        },
      ]);
    } else if (key.endsWith('/villages.json')) {
      return jsonEncode([
        {
          'id': 1,
          'name_th': 'บ้านทดสอบ',
          'moo_no': 2,
          'sub_district_id': 100101,
          'lat': 10.1,
          'long': 100.1,
        },
        {
          'id': 2,
          'name_th': 'บ้านทดสอบ2',
          'moo_no': 1,
          'sub_district_id': 100101,
          'lat': 10.2,
          'long': 100.2,
        },
      ]);
    }
    throw Exception('Asset not found: $key');
  }
}
