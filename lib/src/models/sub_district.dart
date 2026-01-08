import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_district.freezed.dart';

@freezed
class SubDistrict with _$SubDistrict {
  const factory SubDistrict({
    required int id,
    required String zipCode, // String for safety (leading zeros)
    required String nameTh,
    required String nameEn,
    required int districtId,
    required double? lat,
    required double? long,
  }) = _SubDistrict;

  factory SubDistrict.fromJson(Map<String, dynamic> json) {
    // Convert zip_code to String if it comes as int
    final zipCode = json['zip_code'];
    return SubDistrict(
      id: json['id'] as int,
      zipCode: zipCode?.toString() ?? '',
      nameTh: json['name_th'] as String,
      nameEn: json['name_en'] as String,
      districtId: json['district_id'] as int,
      lat: (json['lat'] as num?)?.toDouble(),
      long: (json['long'] as num?)?.toDouble(),
    );
  }
}
