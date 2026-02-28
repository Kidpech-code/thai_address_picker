import 'package:flutter/foundation.dart';

/// A lightweight, memory-efficient village record.
///
/// Villages are the largest dataset (~82,000 records) and are loaded
/// **lazily** on-demand to avoid OOM on low-end devices. This class is
/// intentionally minimal — no generated code, no freezed, no JSON
/// serialization overhead.
///
/// ### Memory Budget
///
/// Each [VillageEntry] is ~80 bytes (1 String + 3 ints + 2 nullable doubles).
/// Total for 82,000 entries ≈ **6.5 MB** — loaded only when needed and
/// evictable via `IAddressRepository.clearVillageCache()`.
///
/// ```dart
/// final village = VillageEntry(
///   id: 477014,
///   nameTh: 'ทวีลดา3',
///   mooNo: 7,
///   subDistrictId: 130601,
/// );
///
/// print(village.displayName); // ทวีลดา3 หมู่ 7
/// ```
@immutable
class VillageEntry {
  /// Unique village ID from the data source.
  final int id;

  /// Thai name of the village.
  final String nameTh;

  /// หมู่ (Moo) number. 0 if not assigned.
  final int mooNo;

  /// Foreign key linking to the parent [AddressEntry.subDistrictId].
  final int subDistrictId;

  /// WGS-84 latitude, if available.
  final double? lat;

  /// WGS-84 longitude, if available.
  final double? lng;

  const VillageEntry({
    required this.id,
    required this.nameTh,
    required this.mooNo,
    required this.subDistrictId,
    this.lat,
    this.lng,
  });

  /// Human-readable display name including Moo number.
  ///
  /// Returns `"บ้านทุ่ง หมู่ 3"` or just `"บ้านทุ่ง"` when mooNo is 0.
  String get displayName => mooNo > 0 ? '$nameTh หมู่ $mooNo' : nameTh;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VillageEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VillageEntry($displayName, subDistrict=$subDistrictId)';
}
