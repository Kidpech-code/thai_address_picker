import 'package:flutter/foundation.dart';

/// A single flattened address record combining province, district,
/// sub-district, and zip code into one memory-efficient immutable object.
///
/// ### Why Flat?
///
/// The traditional approach stores [Province], [District], and [SubDistrict]
/// as separate objects with foreign-key references. This means:
/// - **3 separate object allocations** per address combination
/// - **HashMap lookups** to resolve relationships at query time
/// - **~24 bytes of pointer overhead** per reference on 64-bit systems
/// - **Separate index Maps** (provinceMap, districtMap, subDistrictMap)
///   duplicating data across multiple structures
///
/// By flattening into a single record, we:
/// - Reduce object count from ~16,000+ (7,452 sub-districts + 930 districts
///   + 77 provinces + their index maps) to exactly **7,452 AddressEntry**
///   objects in a single contiguous [List]
/// - **Eliminate all relationship lookups** during search (O(1) field access)
/// - Enable **CPU-cache-friendly** sequential access during index building
///
/// ### Memory Budget
///
/// Total: ~7,452 entries × ~250 bytes avg ≈ **1.8 MB** in-memory
/// (vs ~4–6 MB with separate objects, maps, and cross-reference indexes).
///
/// ### Usage
///
/// ```dart
/// final entry = AddressEntry(
///   index: 0,
///   provinceId: 1, districtId: 101, subDistrictId: 100101,
///   provinceTh: 'กรุงเทพมหานคร', provinceEn: 'Bangkok',
///   districtTh: 'พระนคร', districtEn: 'Phra Nakhon',
///   subDistrictTh: 'พระบรมมหาราชวัง', subDistrictEn: 'Phra Borom Maha Ratchawang',
///   zipCode: '10200',
///   lat: 13.751, lng: 100.492,
/// );
///
/// print(entry.fullAddressTh);
/// // พระบรมมหาราชวัง • พระนคร • กรุงเทพมหานคร • 10200
/// ```
@immutable
class AddressEntry {
  // ─── Identity & Index ──────────────────────────────────────────────────

  /// Sequential index in the master entries array.
  ///
  /// Used by [TrigramIndex] posting lists for O(1) entry resolution.
  /// Always equals this entry's position in `IAddressRepository.entries`.
  final int index;

  // ─── IDs (foreign keys from the original normalized schema) ────────────

  final int provinceId;
  final int districtId;
  final int subDistrictId;

  // ─── Thai names ────────────────────────────────────────────────────────

  final String provinceTh;
  final String districtTh;
  final String subDistrictTh;

  // ─── English names ─────────────────────────────────────────────────────

  final String provinceEn;
  final String districtEn;
  final String subDistrictEn;

  // ─── Zip & Geo ─────────────────────────────────────────────────────────

  /// 5-digit Thai postal code, stored as [String] to preserve leading zeros.
  final String zipCode;

  /// WGS-84 latitude of the sub-district centroid, if available.
  final double? lat;

  /// WGS-84 longitude of the sub-district centroid, if available.
  final double? lng;

  // ─── Constructor ───────────────────────────────────────────────────────

  AddressEntry({
    required this.index,
    required this.provinceId,
    required this.districtId,
    required this.subDistrictId,
    required this.provinceTh,
    required this.provinceEn,
    required this.districtTh,
    required this.districtEn,
    required this.subDistrictTh,
    required this.subDistrictEn,
    required this.zipCode,
    this.lat,
    this.lng,
  });

  // ─── Computed Display Strings ──────────────────────────────────────────

  /// Full Thai address: ตำบล/แขวง • อำเภอ/เขต • จังหวัด • รหัสไปรษณีย์
  String get fullAddressTh =>
      '$subDistrictTh • $districtTh • $provinceTh • $zipCode';

  /// Full English address: Sub-district • District • Province • Zip
  String get fullAddressEn =>
      '$subDistrictEn • $districtEn • $provinceEn • $zipCode';

  // ─── Pre-computed Search Text ──────────────────────────────────────────

  /// All searchable fields concatenated and lowercased for fast scoring.
  ///
  /// Lazily initialized on first access, then cached for the lifetime
  /// of this object. Used during the scoring phase after trigram filtering
  /// narrows candidates to a small set (~10–100 entries).
  late final String searchText =
      '$subDistrictTh $subDistrictEn '
              '$districtTh $districtEn '
              '$provinceTh $provinceEn '
              '$zipCode'
          .toLowerCase();

  // ─── Equality ──────────────────────────────────────────────────────────

  /// Two entries are equal if they represent the same sub-district.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressEntry && subDistrictId == other.subDistrictId;

  @override
  int get hashCode => subDistrictId.hashCode;

  @override
  String toString() => 'AddressEntry($fullAddressTh)';
}
