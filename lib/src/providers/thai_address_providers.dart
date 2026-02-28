/// Optional Riverpod integration layer.
///
/// Import this file only when your project is already using Riverpod.
/// The core widgets ([ThaiAddressForm], [ThaiAddressPicker]) and the
/// [ThaiAddressController] have **no dependency** on this file.
///
/// Providers exposed:
/// - [thaiAddressRepositoryProvider] — the [IThaiAddressRepository] singleton.
/// - [repositoryInitProvider]        — `FutureProvider` that triggers init.
/// - [thaiAddressControllerProvider] — `ChangeNotifierProvider<ThaiAddressController>`.
/// - [thaiAddressNotifierProvider]   — legacy `NotifierProvider` (backward compat).
/// - [availableDistrictsProvider]    — convenience derived provider.
/// - [availableSubDistrictsProvider] — convenience derived provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../contracts/i_thai_address_repository.dart';
import '../controllers/thai_address_controller.dart';
import '../models/province.dart';
import '../models/district.dart';
import '../models/sub_district.dart';
import '../models/thai_address.dart';
import '../repository/thai_address_repository.dart';

export '../models/suggestions.dart' show ZipCodeSuggestion, VillageSuggestion;

// ---------------------------------------------------------------------------
// Core providers
// ---------------------------------------------------------------------------

/// Provides the singleton [IThaiAddressRepository].
///
/// Override in tests:
/// ```dart
/// final container = ProviderContainer(overrides: [
///   thaiAddressRepositoryProvider.overrideWithValue(MockThaiAddressRepository()),
/// ]);
/// ```
final thaiAddressRepositoryProvider = Provider<IThaiAddressRepository>((ref) {
  return ThaiAddressRepository();
});

/// Triggers repository initialization.  `watch` this in any widget that needs
/// the data to be ready (only necessary in the Riverpod path).
final repositoryInitProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(thaiAddressRepositoryProvider);
  await repository.initialize();
});

/// Provides a [ThaiAddressController] whose lifecycle is managed by Riverpod.
///
/// For non-Riverpod usage, create the controller manually and pass it to
/// [ThaiAddressForm].
final thaiAddressControllerProvider =
    ChangeNotifierProvider<ThaiAddressController>((ref) {
      final repo = ref.watch(thaiAddressRepositoryProvider);
      return ThaiAddressController(repository: repo);
    });

// ---------------------------------------------------------------------------
// Legacy NotifierProvider (backward compatibility)
// ---------------------------------------------------------------------------

/// Immutable selection state used by [ThaiAddressNotifier].
class ThaiAddressState {
  final Province? selectedProvince;
  final District? selectedDistrict;
  final SubDistrict? selectedSubDistrict;
  final String? zipCode;
  final bool isLoading;
  final String? error;

  const ThaiAddressState({
    this.selectedProvince,
    this.selectedDistrict,
    this.selectedSubDistrict,
    this.zipCode,
    this.isLoading = false,
    this.error,
  });

  ThaiAddressState copyWith({
    Province? selectedProvince,
    District? selectedDistrict,
    SubDistrict? selectedSubDistrict,
    String? zipCode,
    bool? isLoading,
    String? error,
    bool clearProvince = false,
    bool clearDistrict = false,
    bool clearSubDistrict = false,
    bool clearZipCode = false,
  }) {
    return ThaiAddressState(
      selectedProvince: clearProvince
          ? null
          : (selectedProvince ?? this.selectedProvince),
      selectedDistrict: clearDistrict
          ? null
          : (selectedDistrict ?? this.selectedDistrict),
      selectedSubDistrict: clearSubDistrict
          ? null
          : (selectedSubDistrict ?? this.selectedSubDistrict),
      zipCode: clearZipCode ? null : (zipCode ?? this.zipCode),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  ThaiAddress toThaiAddress() => ThaiAddress(
    provinceTh: selectedProvince?.nameTh,
    provinceEn: selectedProvince?.nameEn,
    provinceId: selectedProvince?.id,
    districtTh: selectedDistrict?.nameTh,
    districtEn: selectedDistrict?.nameEn,
    districtId: selectedDistrict?.id,
    subDistrictTh: selectedSubDistrict?.nameTh,
    subDistrictEn: selectedSubDistrict?.nameEn,
    subDistrictId: selectedSubDistrict?.id,
    zipCode: zipCode,
    lat: selectedSubDistrict?.lat,
    long: selectedSubDistrict?.long,
  );
}

/// Notifier that mirrors [ThaiAddressController] logic for Riverpod consumers.
///
/// Prefer [ThaiAddressController] + [ThaiAddressForm] for new code.  This
/// class is retained for backward compatibility only.
class ThaiAddressNotifier extends Notifier<ThaiAddressState> {
  late final IThaiAddressRepository _repository;

  @override
  ThaiAddressState build() {
    _repository = ref.watch(thaiAddressRepositoryProvider);
    return const ThaiAddressState();
  }

  void selectProvince(Province? province) {
    state = state.copyWith(
      selectedProvince: province,
      clearProvince: province == null,
      clearDistrict: true,
      clearSubDistrict: true,
      clearZipCode: true,
    );
  }

  void selectDistrict(District? district) {
    state = state.copyWith(
      selectedDistrict: district,
      clearDistrict: district == null,
      clearSubDistrict: true,
      clearZipCode: true,
    );
  }

  void selectSubDistrict(SubDistrict? subDistrict) {
    state = state.copyWith(
      selectedSubDistrict: subDistrict,
      clearSubDistrict: subDistrict == null,
      zipCode: subDistrict?.zipCode,
      clearZipCode: subDistrict == null,
    );
  }

  void setZipCode(String zipCode) {
    if (zipCode.isEmpty) {
      state = state.copyWith(
        clearZipCode: true,
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
      return;
    }
    if (zipCode.length < 5) {
      state = state.copyWith(
        zipCode: zipCode,
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
      return;
    }
    final subs = _repository.getSubDistrictsByZipCode(zipCode);
    if (subs.isEmpty) {
      state = state.copyWith(
        zipCode: zipCode,
        error: 'ไม่พบรหัสไปรษณีย์นี้',
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
    } else if (subs.length == 1) {
      final sub = subs.first;
      final district = _repository.getDistrictById(sub.districtId);
      final province = district != null
          ? _repository.getProvinceById(district.provinceId)
          : null;
      state = ThaiAddressState(
        selectedProvince: province,
        selectedDistrict: district,
        selectedSubDistrict: sub,
        zipCode: zipCode,
      );
    } else {
      state = state.copyWith(
        zipCode: zipCode,
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
    }
  }

  void selectZipCodeSuggestion(ZipCodeSuggestion suggestion) {
    state = ThaiAddressState(
      selectedProvince: suggestion.province,
      selectedDistrict: suggestion.district,
      selectedSubDistrict: suggestion.subDistrict,
      zipCode: suggestion.zipCode,
    );
  }

  void reset() => state = const ThaiAddressState();

  void clearZipCode() => state = state.copyWith(clearZipCode: true);

  List<District> getAvailableDistricts() {
    if (state.selectedProvince == null) return const [];
    return _repository.getDistrictsByProvince(state.selectedProvince!.id);
  }

  List<SubDistrict> getAvailableSubDistricts() {
    if (state.selectedDistrict == null) return const [];
    return _repository.getSubDistrictsByDistrict(state.selectedDistrict!.id);
  }

  List<Province> getAllProvinces() => _repository.provinces;
  List<Province> searchProvinces(String q) => _repository.searchProvinces(q);
  List<District> searchDistricts(String q) =>
      _repository.searchDistricts(q, provinceId: state.selectedProvince?.id);
  List<SubDistrict> searchSubDistricts(String q) =>
      _repository.searchSubDistricts(q, districtId: state.selectedDistrict?.id);
  List<ZipCodeSuggestion> searchZipCodes(String q, {int maxResults = 20}) =>
      _repository.searchZipCodes(q, maxResults: maxResults);
}

/// Legacy provider — prefer [thaiAddressControllerProvider] for new code.
final thaiAddressNotifierProvider =
    NotifierProvider<ThaiAddressNotifier, ThaiAddressState>(
      ThaiAddressNotifier.new,
    );

// ---------------------------------------------------------------------------
// Convenience derived providers
// ---------------------------------------------------------------------------

final availableDistrictsProvider = Provider<List<District>>((ref) {
  final state = ref.watch(thaiAddressNotifierProvider);
  if (state.selectedProvince == null) return const [];
  return ref.read(thaiAddressNotifierProvider.notifier).getAvailableDistricts();
});

final availableSubDistrictsProvider = Provider<List<SubDistrict>>((ref) {
  final state = ref.watch(thaiAddressNotifierProvider);
  if (state.selectedDistrict == null) return const [];
  return ref
      .read(thaiAddressNotifierProvider.notifier)
      .getAvailableSubDistricts();
});
