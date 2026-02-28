import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../contracts/i_thai_address_repository.dart';
import '../models/province.dart';
import '../models/district.dart';
import '../models/sub_district.dart';
import '../models/thai_address.dart';
import '../models/suggestions.dart';

// ---------------------------------------------------------------------------
// ThaiAddressSelection — immutable snapshot of the current address state
// ---------------------------------------------------------------------------

/// Immutable value object representing the current state of address selection.
///
/// Held inside [ThaiAddressController] as its [ValueNotifier] value.
@immutable
class ThaiAddressSelection {
  final Province? province;
  final District? district;
  final SubDistrict? subDistrict;
  final String? zipCode;
  final String? error;

  const ThaiAddressSelection({
    this.province,
    this.district,
    this.subDistrict,
    this.zipCode,
    this.error,
  });

  /// Empty / initial state with no selections.
  static const ThaiAddressSelection empty = ThaiAddressSelection();

  /// Create a modified copy.  Use `clearXxx = true` to explicitly null a field.
  ThaiAddressSelection copyWith({
    Province? province,
    District? district,
    SubDistrict? subDistrict,
    String? zipCode,
    String? error,
    bool clearProvince = false,
    bool clearDistrict = false,
    bool clearSubDistrict = false,
    bool clearZipCode = false,
    bool clearError = false,
  }) {
    return ThaiAddressSelection(
      province: clearProvince ? null : (province ?? this.province),
      district: clearDistrict ? null : (district ?? this.district),
      subDistrict: clearSubDistrict ? null : (subDistrict ?? this.subDistrict),
      zipCode: clearZipCode ? null : (zipCode ?? this.zipCode),
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Convert the current selection to the public [ThaiAddress] model.
  ThaiAddress toThaiAddress() => ThaiAddress(
    provinceTh: province?.nameTh,
    provinceEn: province?.nameEn,
    provinceId: province?.id,
    districtTh: district?.nameTh,
    districtEn: district?.nameEn,
    districtId: district?.id,
    subDistrictTh: subDistrict?.nameTh,
    subDistrictEn: subDistrict?.nameEn,
    subDistrictId: subDistrict?.id,
    zipCode: zipCode,
    lat: subDistrict?.lat,
    long: subDistrict?.long,
  );

  bool get isEmpty =>
      province == null &&
      district == null &&
      subDistrict == null &&
      zipCode == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThaiAddressSelection &&
          province == other.province &&
          district == other.district &&
          subDistrict == other.subDistrict &&
          zipCode == other.zipCode &&
          error == other.error;

  @override
  int get hashCode =>
      Object.hash(province, district, subDistrict, zipCode, error);

  @override
  String toString() =>
      'ThaiAddressSelection(province: ${province?.nameTh}, '
      'district: ${district?.nameTh}, '
      'subDistrict: ${subDistrict?.nameTh}, '
      'zipCode: $zipCode, error: $error)';
}

// ---------------------------------------------------------------------------
// ThaiAddressController — ValueNotifier, no Riverpod dependency
// ---------------------------------------------------------------------------

/// State-management controller for Thai address selection.
///
/// Designed to be as ergonomic as a standard Flutter [TextEditingController]:
///
/// ```dart
/// // 1. Create once (e.g. in State.initState or a DI container)
/// final controller = ThaiAddressController(
///   repository: ThaiAddressRepository(),
/// );
///
/// // 2. Initialise the data source
/// await controller.initialize();
///
/// // 3. Optionally seed an initial address
/// await controller.setFromThaiAddress(existingAddress);
///
/// // 4. Feed to the widget tree
/// ThaiAddressForm(controller: controller)
///
/// // 5. Read current value at any time
/// final address = controller.toThaiAddress();
///
/// // 6. Dispose together with the widget that owns it
/// controller.dispose();
/// ```
///
/// The controller extends [ValueNotifier]<[ThaiAddressSelection]>, so widgets
/// can react to changes via [ValueListenableBuilder] or [addListener] — no
/// Riverpod, BLoC, or any other state management library required.
class ThaiAddressController extends ValueNotifier<ThaiAddressSelection> {
  /// The underlying data source.  Inject a mock to make widgets unit-testable.
  final IThaiAddressRepository repository;

  /// Coalesces concurrent [initialize] calls into a single future.
  Future<void>? _initFuture;

  ThaiAddressController({
    required this.repository,
    ThaiAddressSelection? initial,
  }) : super(initial ?? ThaiAddressSelection.empty);

  // ── Lifecycle ──────────────────────────────────────────────────────────

  /// `true` once [initialize] has completed.
  bool get isReady => repository.isInitialized;

  /// Initialise the underlying repository.  Safe to call multiple times and
  /// from multiple places — the work is done only once.
  ///
  /// Supply [bundle] when using a custom [AssetBundle] (e.g. in tests).
  Future<void> initialize({AssetBundle? bundle, bool useIsolate = true}) {
    _initFuture ??= _doInitialize(bundle: bundle, useIsolate: useIsolate);
    return _initFuture!;
  }

  Future<void> _doInitialize({
    AssetBundle? bundle,
    bool useIsolate = true,
  }) async {
    await repository.initialize(bundle: bundle, useIsolate: useIsolate);
    // Notify listeners so FutureBuilder / ValueListenableBuilder rebuild.
    notifyListeners();
  }

  // ── Address mutations ──────────────────────────────────────────────────

  /// Select a province and cascade-clear district, sub-district, and zip code.
  void selectProvince(Province? province) {
    value = value.copyWith(
      province: province,
      clearProvince: province == null,
      clearDistrict: true,
      clearSubDistrict: true,
      clearZipCode: true,
      clearError: true,
    );
  }

  /// Select a district and cascade-clear sub-district and zip code.
  void selectDistrict(District? district) {
    value = value.copyWith(
      district: district,
      clearDistrict: district == null,
      clearSubDistrict: true,
      clearZipCode: true,
      clearError: true,
    );
  }

  /// Select a sub-district and auto-fill zip code.
  void selectSubDistrict(SubDistrict? subDistrict) {
    value = value.copyWith(
      subDistrict: subDistrict,
      clearSubDistrict: subDistrict == null,
      zipCode: subDistrict?.zipCode,
      clearZipCode: subDistrict == null,
      clearError: true,
    );
  }

  /// Set a (partial or full) zip code and perform reverse-lookup when 5 digits.
  ///
  /// - Empty string → clears all fields.
  /// - 1–4 digits   → stores zip; clears sub/district/province for fresh pick.
  /// - 5 digits, single match  → auto-fills all fields.
  /// - 5 digits, multiple matches → stores zip; user selects the sub-district.
  /// - 5 digits, no match → shows an error.
  void setZipCode(String zipCode) {
    if (zipCode.isEmpty) {
      value = ThaiAddressSelection.empty;
      return;
    }

    if (zipCode.length < 5) {
      value = value.copyWith(
        zipCode: zipCode,
        clearError: true,
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
      return;
    }

    final subs = repository.getSubDistrictsByZipCode(zipCode);

    if (subs.isEmpty) {
      value = value.copyWith(
        zipCode: zipCode,
        error: 'ไม่พบรหัสไปรษณีย์นี้',
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
    } else if (subs.length == 1) {
      final sub = subs.first;
      final district = repository.getDistrictById(sub.districtId);
      final province = district != null
          ? repository.getProvinceById(district.provinceId)
          : null;
      value = ThaiAddressSelection(
        province: province,
        district: district,
        subDistrict: sub,
        zipCode: zipCode,
      );
    } else {
      // Multiple sub-districts share this zip — user must pick one.
      value = value.copyWith(
        zipCode: zipCode,
        clearError: true,
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
    }
  }

  /// Apply a [ZipCodeSuggestion] selected from the autocomplete dropdown,
  /// auto-filling province, district, sub-district and zip code.
  void selectZipCodeSuggestion(ZipCodeSuggestion suggestion) {
    value = ThaiAddressSelection(
      province: suggestion.province,
      district: suggestion.district,
      subDistrict: suggestion.subDistrict,
      zipCode: suggestion.zipCode,
    );
  }

  /// Reset all fields to the empty state.
  void reset() => value = ThaiAddressSelection.empty;

  /// Clear only the zip code field (e.g. when switching to manual entry).
  void clearZipCode() =>
      value = value.copyWith(clearZipCode: true, clearError: true);

  /// Seed the controller from a previously saved [ThaiAddress].
  ///
  /// Requires [initialize] to have completed (IDs are used for lookups).
  void setFromThaiAddress(ThaiAddress address) {
    final province = address.provinceId != null
        ? repository.getProvinceById(address.provinceId!)
        : null;
    final district = address.districtId != null
        ? repository.getDistrictById(address.districtId!)
        : null;
    final subDistrict = address.subDistrictId != null
        ? repository.getSubDistrictById(address.subDistrictId!)
        : null;

    value = ThaiAddressSelection(
      province: province,
      district: district,
      subDistrict: subDistrict,
      zipCode: address.zipCode,
    );
  }

  // ── Convenience read accessors ─────────────────────────────────────────

  Province? get selectedProvince => value.province;
  District? get selectedDistrict => value.district;
  SubDistrict? get selectedSubDistrict => value.subDistrict;
  String? get zipCode => value.zipCode;
  String? get error => value.error;

  /// Convert the current selection to the public [ThaiAddress] model.
  ThaiAddress toThaiAddress() => value.toThaiAddress();

  // ── Repository query delegation ────────────────────────────────────────

  List<Province> getAllProvinces() => repository.provinces;
  List<Province> searchProvinces(String q) => repository.searchProvinces(q);

  List<District> getAvailableDistricts() {
    final p = value.province;
    if (p == null) return const [];
    return repository.getDistrictsByProvince(p.id);
  }

  List<District> searchDistricts(String q) =>
      repository.searchDistricts(q, provinceId: value.province?.id);

  List<SubDistrict> getAvailableSubDistricts() {
    final d = value.district;
    if (d == null) return const [];
    return repository.getSubDistrictsByDistrict(d.id);
  }

  List<SubDistrict> searchSubDistricts(String q) =>
      repository.searchSubDistricts(q, districtId: value.district?.id);

  List<ZipCodeSuggestion> searchZipCodes(String q, {int maxResults = 20}) =>
      repository.searchZipCodes(q, maxResults: maxResults);
}
