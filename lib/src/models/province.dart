import 'package:freezed_annotation/freezed_annotation.dart';

part 'province.freezed.dart';

@freezed
class Province with _$Province {
  const factory Province({
    required int id,
    required String nameTh,
    required String nameEn,
    required int geographyId,
  }) = _Province;

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] as int,
      nameTh: json['name_th'] as String,
      nameEn: json['name_en'] as String,
      geographyId: json['geography_id'] as int,
    );
  }
}
