import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/province.dart';
import '../models/district.dart';
import '../models/sub_district.dart';
import '../models/thai_address.dart';
import '../repository/thai_address_repository.dart';

/// Provider for the repository (singleton)
final thaiAddressRepositoryProvider = Provider<ThaiAddressRepository>((ref) {
  return ThaiAddressRepository();
});

/// Provider to initialize the repository
final repositoryInitProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(thaiAddressRepositoryProvider);
  await repository.initialize();
});

/// State class for Thai address selection
class ThaiAddressState {
  final Province? selectedProvince;
  final District? selectedDistrict;
  final SubDistrict? selectedSubDistrict;
  final String? zipCode;
  final bool isLoading;
  final String? error;

  ThaiAddressState({
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

  /// Convert to ThaiAddress model
  ThaiAddress toThaiAddress() {
    return ThaiAddress(
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
}

/// Notifier for managing Thai address selection with cascading logic
///
/// Provides state management for address selection with:
/// - Cascading updates (Province → District → SubDistrict → Zip)
/// - Reverse lookup (Zip Code → auto-fill all fields)
/// - Real-time validation and error handling
/// - Search functionality for all address levels
///
/// Usage with Riverpod:
/// ```dart
/// final notifier = ref.read(thaiAddressNotifierProvider.notifier);
/// notifier.selectProvince(province);
/// ```
class ThaiAddressNotifier extends Notifier<ThaiAddressState> {
  late final ThaiAddressRepository _repository;

  @override
  ThaiAddressState build() {
    _repository = ref.watch(thaiAddressRepositoryProvider);
    return ThaiAddressState();
  }

  /// Select a province (cascading: clears district, subdistrict, and zip code)
  void selectProvince(Province? province) {
    state = state.copyWith(
      selectedProvince: province,
      clearDistrict: true,
      clearSubDistrict: true,
      clearZipCode: true,
    );
  }

  /// Select a district (cascading: clears subdistrict and zip code)
  void selectDistrict(District? district) {
    state = state.copyWith(
      selectedDistrict: district,
      clearSubDistrict: true,
      clearZipCode: true,
    );
  }

  /// Select a subdistrict (auto-fills zip code)
  void selectSubDistrict(SubDistrict? subDistrict) {
    state = state.copyWith(
      selectedSubDistrict: subDistrict,
      zipCode: subDistrict?.zipCode,
    );
  }

  /// Reverse lookup: Set zip code and auto-fill address if unique
  ///
  /// Handles three scenarios:
  /// 1. **Empty input**: Clears all fields
  /// 2. **Partial input (< 5 digits)**: Stores zip without error, allows autocomplete
  /// 3. **Complete input (5 digits)**:
  ///    - Single match → Auto-fills all fields
  ///    - Multiple matches → Stores zip, user must select from suggestions
  ///    - No match → Shows error message
  ///
  /// This supports real-time autocomplete from the first digit typed.
  ///
  /// Parameters:
  /// - [zipCode]: User input (1-5 digits)
  void setZipCode(String zipCode) {
    if (zipCode.isEmpty) {
      state = state.copyWith(
        clearZipCode: true,
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
        error: null,
      );
      return;
    }

    // For partial input (less than 5 digits), just store zip code without error
    // This allows autocomplete to work while typing
    if (zipCode.length < 5) {
      state = state.copyWith(
        zipCode: zipCode,
        error: null,
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
      return;
    }

    // For complete 5-digit zip code, do full lookup
    final subDistricts = _repository.getSubDistrictsByZipCode(zipCode);

    if (subDistricts.isEmpty) {
      // Invalid zip code
      state = state.copyWith(
        zipCode: zipCode,
        error: 'ไม่พบรหัสไปรษณีย์นี้',
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
    } else if (subDistricts.length == 1) {
      // Unique zip code - auto-fill everything
      final subDistrict = subDistricts.first;
      final district = _repository.getDistrictById(subDistrict.districtId);
      final province = district != null
          ? _repository.getProvinceById(district.provinceId)
          : null;

      state = ThaiAddressState(
        selectedProvince: province,
        selectedDistrict: district,
        selectedSubDistrict: subDistrict,
        zipCode: zipCode,
        error: null,
      );
    } else {
      // Multiple subdistricts with same zip code - just set zip code
      state = state.copyWith(
        zipCode: zipCode,
        error: null,
        clearSubDistrict: true,
        clearDistrict: true,
        clearProvince: true,
      );
    }
  }

  /// Reset all selections
  void reset() {
    state = ThaiAddressState();
  }

  /// Get available districts for selected province
  List<District> getAvailableDistricts() {
    if (state.selectedProvince == null) return [];
    return _repository.getDistrictsByProvince(state.selectedProvince!.id);
  }

  /// Get available subdistricts for selected district
  List<SubDistrict> getAvailableSubDistricts() {
    if (state.selectedDistrict == null) return [];
    return _repository.getSubDistrictsByDistrict(state.selectedDistrict!.id);
  }

  /// Get all provinces
  List<Province> getAllProvinces() {
    return _repository.provinces;
  }

  /// Search provinces
  List<Province> searchProvinces(String query) {
    return _repository.searchProvinces(query);
  }

  /// Search districts
  List<District> searchDistricts(String query) {
    return _repository.searchDistricts(
      query,
      provinceId: state.selectedProvince?.id,
    );
  }

  /// Search subdistricts
  List<SubDistrict> searchSubDistricts(String query) {
    return _repository.searchSubDistricts(
      query,
      districtId: state.selectedDistrict?.id,
    );
  }

  /// Search zip codes with suggestions
  /// Returns list of ZipCodeSuggestion for autocomplete
  List<ZipCodeSuggestion> searchZipCodes(String query, {int maxResults = 20}) {
    return _repository.searchZipCodes(query, maxResults: maxResults);
  }

  /// Select from zip code suggestion
  /// Auto-fills all related fields (subdistrict, district, province)
  void selectZipCodeSuggestion(ZipCodeSuggestion suggestion) {
    state = ThaiAddressState(
      selectedProvince: suggestion.province,
      selectedDistrict: suggestion.district,
      selectedSubDistrict: suggestion.subDistrict,
      zipCode: suggestion.zipCode,
      error: null,
    );
  }
}

/// Provider for the Thai address notifier
final thaiAddressNotifierProvider =
    NotifierProvider<ThaiAddressNotifier, ThaiAddressState>(() {
      return ThaiAddressNotifier();
    });

/// Convenience providers for filtering data based on current selection
final availableDistrictsProvider = Provider<List<District>>((ref) {
  final notifier = ref.watch(thaiAddressNotifierProvider.notifier);
  final state = ref.watch(thaiAddressNotifierProvider);

  if (state.selectedProvince == null) return [];
  return notifier.getAvailableDistricts();
});

final availableSubDistrictsProvider = Provider<List<SubDistrict>>((ref) {
  final notifier = ref.watch(thaiAddressNotifierProvider.notifier);
  final state = ref.watch(thaiAddressNotifierProvider);

  if (state.selectedDistrict == null) return [];
  return notifier.getAvailableSubDistricts();
});
