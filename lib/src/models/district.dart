import 'package:freezed_annotation/freezed_annotation.dart';

part 'district.freezed.dart';

@freezed
class District with _$District {
  const factory District({required int id, required String nameTh, required String nameEn, required int provinceId}) = _District;

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as int,
      nameTh: json['name_th'] as String,
      nameEn: json['name_en'] as String,
      provinceId: json['province_id'] as int,
    );
  }
}
