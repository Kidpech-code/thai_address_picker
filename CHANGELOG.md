# Changelog

All notable changes to this project will be documented in this file.

## [1.0.4] - 2025-01-09

### Added

- upgrade dependencies Support for Dart SDK 3.8.1 and above

## [1.0.3] - 2025-01-09

### Added

- Support for Dart SDK 3.8.1 and above

## [1.0.2] - 2025-01-08

### Added

- ✨ **New Feature**: `showZipCodeAutocomplete` parameter in `ThaiAddressForm`
  - Can now disable zip code autocomplete to show a simple TextField instead
  - Default: `true` (autocomplete enabled)
  - When `false`: Shows basic TextField without suggestions
- 📚 **New Examples**:
  - `disable_zipcode_autocomplete_example.dart` - Basic example with disabled autocomplete
  - `compare_zipcode_modes_example.dart` - Side-by-side comparison of both modes
- 🆕 `clearZipCode()` method in `ThaiAddressNotifier` for better state management

### Changed

- 📖 Updated README.md with:
  - Documentation for disabling zip code autocomplete
  - Comparison table of features (Autocomplete vs Simple)
  - Links to new example files
  - Complete Example Files section

### Why This Update?

- Some users don't need autocomplete suggestions
- Simpler UI for cases where users already know their zip code
- Better performance for basic input scenarios
- More flexibility and customization options

---

## [1.0.1] - 2025-01-08

### Added

- 📚 Enhanced documentation with usage examples
- ⚠️ Helpful error messages and warnings for optional dependencies (GetX, Provider)
- 🛡️ Better error handling in example files

### Fixed

- 🐛 Fixed example code that called non-existent `getZipCodesBySubDistrict()` method
  - Changed to use `subDistrict.zipCode` directly for accurate zip code retrieval
  - Applied fixes to: `repository_only_example.dart`, `standalone_usage_example.dart`
- 🔧 Resolved null type issues in cascading selection logic
  - Fixed `firstWhere()` callbacks to properly handle null returns
  - Applied to Province, District, and SubDistrict lookups
- 📝 Fixed dangling doc comments in example files
- ✅ All dart analyze issues resolved - zero issues found

### Changed

- 📦 Updated example files to properly handle optional dependencies
  - GetX and Provider examples now clearly indicate they require additional setup
  - Added helpful error messages in main menu when dependencies are missing
- 🧹 Improved code organization in example implementations

### Documentation

- 📖 Updated README.md with version 1.0.1
- 🎯 Clarified optional dependency requirements for integration examples

---

## [1.0.0] - 2025-01-08

### Added

- 🧪 comprehensive tests for Thai address picker functionality
- Implement unit tests for ThaiAddressNotifier to validate state management and selection logic for provinces, districts, sub-districts, and zip codes.
- Create widget tests for ThaiAddressForm to ensure proper rendering, interaction, and state updates based on user input.
- Develop tests for various components including village and zip code autocomplete to verify suggestion handling and selection callbacks.
- Enhance coverage for picker dialogs and bottom sheets to confirm correct display and interaction behavior.
- Ensure all tests utilize a fake asset bundle for consistent and isolated testing environments.

### Changed

- 📦 Bumped package version to 1.0.0
- 📝 Updated documentation to reflect new version and testing features

### Fixed

- 🐛 Resolved minor bugs identified during testing phase

### Performance

- ⚡ Optimized test execution time and reliability

### Documentation

- 📖 Added test documentation and usage examples

## [0.3.0] - 2025-01-08

### Added

- 🏘️ **Village Autocomplete Widget** - Real-time village (หมู่บ้าน) search
  - Substring matching for flexible Thai text search
  - Shows full address hierarchy: Village • หมู่ที่ • SubDistrict • District • Province
  - Displays Moo number (หมู่ที่) for accurate identification
  - Auto-fills all address fields when selected
  - High-performance O(k) algorithm with early exit optimization
  - **Real-time updates from first character typed**
- 🔍 `searchVillages()` method in repository with smart filtering
- 🏘️ `VillageSuggestion` class for village autocomplete data
- 📚 New example: `village_autocomplete_example.dart` with full feature showcase
- 📊 Village data integration (~70,000+ villages)
- 📝 Spec file: `assets/data/spec/village.json` for data structure

### Changed

- 📦 Updated package description to include Village support
- 🎨 Enhanced repository to handle village search efficiently
- 🔄 Improved data loading to include villages.json

### Performance

- ⚡ O(k) complexity for village search with early exit (k = maxResults ≤ 20)
- 🚀 Substring matching optimization for Thai text
- 💾 Efficient HashMap-based filtering
- 🎯 No unnecessary state updates during search

### Documentation

- 📖 Updated README with Village Autocomplete usage
- 📝 Enhanced code comments for village-related features
- 🎓 Added comprehensive example for village search
- 📚 Updated feature list and documentation

## [0.2.0] - 2025-01-07

### Added

- ✨ **Zip Code Autocomplete Widget** - Real-time auto-suggestions while typing
  - Prefix matching for accurate suggestions (รหัสที่เริ่มต้นด้วย...)
  - Shows full address hierarchy: ZipCode → SubDistrict → District → Province
  - Handles multiple areas with same zip code (e.g., 10200 has 3 areas)
  - Auto-fills all fields when suggestion is selected
  - High-performance O(k log k) algorithm with early exit optimization
  - **Real-time updates from first digit typed**
- 🔍 `searchZipCodes()` method in repository with smart filtering
- 🎯 `selectZipCodeSuggestion()` in provider for auto-fill cascade
- 📚 New example: `zip_code_autocomplete_example.dart` with full feature showcase
- 📖 Comprehensive documentation: `ZIP_CODE_AUTOCOMPLETE.md`

### Changed

- 🔄 `ThaiAddressForm` now uses `ZipCodeAutocomplete` instead of plain TextField
- ⚡ Improved zip code input UX with real-time suggestions from first digit
- 🎨 Enhanced helper text: "ระบบจะแนะนำที่อยู่อัตโนมัติ"
- 🚀 Optimized `setZipCode()` to handle partial input (< 5 digits) without errors

### Fixed

- 🐛 Fixed issue with multiple subdistricts having same zip code
- 🔧 Improved error state handling in zip code lookup
- ✅ Clear selections properly when zip code has multiple areas
- 🎯 Fixed autocomplete to show suggestions from first digit (not just 5 digits)

### Performance

- ⚡ O(k) complexity for zip code search with early exit (k = maxResults ≤ 20)
- 🚀 Prefix matching optimization for real-time responsiveness
- 💾 Efficient HashMap-based unique filtering
- 🎯 No unnecessary state updates during partial input

### Documentation

- 📖 Updated README with Zip Code Autocomplete usage
- 📝 Added comprehensive technical documentation
- 🎓 Enhanced code comments for better maintainability
- 📚 Added example showcasing all features

## [0.1.0] - 2025-10-15

### Added

- 🚀 Released version 0.1.0 with minor improvements and bug fixe

### Fixed

- 🐛 Fixed minor bugs in address selection logic

## [0.0.1] - 2025-01-07

### Added

- 🎉 Initial release of Thai Address Picker
- 📦 Data models for Geography, Province, District, SubDistrict, and ThaiAddress using Freezed
- 🏗️ Repository pattern with isolate-based JSON parsing for high performance
- 💾 In-memory caching with indexed lookups for O(1) search complexity
- 🔄 Cascading selection logic (Province → District → SubDistrict → Zip Code)
- 🔍 Reverse lookup functionality (Zip Code → Auto-fill address)
- 🎨 `ThaiAddressForm` widget - Complete inline form with 4 fields
- 📱 `ThaiAddressPicker.showBottomSheet()` - Bottom sheet picker UI
- 💬 `ThaiAddressPicker.showDialog()` - Dialog picker UI
- 🌐 Bilingual support (Thai and English)
- ⚡ High-performance background JSON parsing using compute (Isolates)
- 🎯 State management using flutter_riverpod
- 🔧 Customizable styling and decoration for all form fields
- 📍 Latitude/longitude coordinates for sub-districts
- 🔎 Search functionality for provinces, districts, and sub-districts
- 📊 Complete Thai address database with ~77 provinces, ~900+ districts, and 7,000+ sub-districts

### Features

- Clean Architecture with separation of concerns
- Singleton repository pattern for efficient data management
- Type-safe models with null safety
- Extensive documentation and examples
- Easy integration with existing Riverpod or non-Riverpod apps
- Handles edge cases (multiple sub-districts per zip code)

### Developer Experience

- Simple API with minimal boilerplate
- Comprehensive README with usage examples
- Example app demonstrating all features
- Clear error messages and state handling
- Flexible customization options
