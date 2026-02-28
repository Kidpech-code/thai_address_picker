import 'province.dart';
import 'district.dart';
import 'sub_district.dart';
import 'village.dart';

/// Encapsulates a single zip-code autocomplete suggestion with its full
/// address hierarchy.
///
/// Used by [ZipCodeAutocomplete] and [IThaiAddressRepository.searchZipCodes].
class ZipCodeSuggestion {
  final String zipCode;
  final SubDistrict subDistrict;
  final District? district;
  final Province? province;

  const ZipCodeSuggestion({
    required this.zipCode,
    required this.subDistrict,
    this.district,
    this.province,
  });

  /// Thai format: `10200 • บางรัก • บางรัก • กรุงเทพมหานคร`
  String get displayText {
    final parts = <String>[zipCode];
    if (subDistrict.nameTh.isNotEmpty) parts.add(subDistrict.nameTh);
    if (district?.nameTh != null) parts.add(district!.nameTh);
    if (province?.nameTh != null) parts.add(province!.nameTh);
    return parts.join(' • ');
  }

  /// English format secondary line
  String get displayTextEn {
    final parts = <String>[];
    if (subDistrict.nameEn.isNotEmpty) parts.add(subDistrict.nameEn);
    if (district?.nameEn != null) parts.add(district!.nameEn);
    if (province?.nameEn != null) parts.add(province!.nameEn);
    return parts.isEmpty ? '' : parts.join(' • ');
  }

  @override
  String toString() => displayText;
}

/// Encapsulates a single village autocomplete suggestion with its full
/// address hierarchy.
///
/// Used by [VillageAutocomplete] and [IThaiAddressRepository.searchVillages].
class VillageSuggestion {
  final Village village;
  final SubDistrict? subDistrict;
  final District? district;
  final Province? province;

  const VillageSuggestion({
    required this.village,
    this.subDistrict,
    this.district,
    this.province,
  });

  /// Thai format: `บ้านทุ่ง • หมู่ 3 • ตำบล... • อำเภอ... • จังหวัด...`
  String get displayText {
    final parts = <String>[village.nameTh];
    if (village.mooNo > 0) parts.add('หมู่ ${village.mooNo}');
    if (subDistrict?.nameTh != null) parts.add(subDistrict!.nameTh);
    if (district?.nameTh != null) parts.add(district!.nameTh);
    if (province?.nameTh != null) parts.add(province!.nameTh);
    return parts.join(' • ');
  }

  /// `หมู่ที่ X` display string (empty when mooNo is 0)
  String get displayMoo => village.mooNo > 0 ? 'หมู่ ${village.mooNo}' : '';

  @override
  String toString() => displayText;
}
