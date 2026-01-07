import 'package:freezed_annotation/freezed_annotation.dart';

part 'village.freezed.dart';

@freezed
class Village with _$Village {
  const factory Village({
    required int id,
    required String nameTh,
    required int mooNo,
    required int subDistrictId,
    required double? lat,
    required double? long,
  }) = _Village;

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'] as int,
      nameTh: json['name_th'] as String,
      mooNo: json['moo_no'] as int,
      subDistrictId: json['sub_district_id'] as int,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      long: json['long'] != null ? (json['long'] as num).toDouble() : null,
    );
  }
}
