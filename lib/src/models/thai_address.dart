import 'package:freezed_annotation/freezed_annotation.dart';

part 'thai_address.freezed.dart';

/// The complete Thai address model returned to the user
@freezed
class ThaiAddress with _$ThaiAddress {
  const factory ThaiAddress({
    String? provinceTh,
    String? provinceEn,
    int? provinceId,
    String? districtTh,
    String? districtEn,
    int? districtId,
    String? subDistrictTh,
    String? subDistrictEn,
    int? subDistrictId,
    String? zipCode,
    double? lat,
    double? long,
  }) = _ThaiAddress;
}
