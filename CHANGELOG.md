# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2025-01-07

### Added

- ✨ **Zip Code Autocomplete Widget** - Real-time auto-suggestions while typing
  - Prefix matching for accurate suggestions (รหัสที่เริ่มต้นด้วย...)
  - Shows full address hierarchy: ZipCode → SubDistrict → District → Province
  - Handles multiple areas with same zip code (e.g., 10200 has 3 areas)
  - Auto-fills all fields when suggestion is selected
  - High-performance O(k log k) algorithm with early exit optimization
- 🔍 `searchZipCodes()` method in repository with smart filtering
- 🎯 `selectZipCodeSuggestion()` in provider for auto-fill cascade
- 📚 New example: `zip_code_autocomplete_example.dart` with full feature showcase
- 📖 Comprehensive documentation: `ZIP_CODE_AUTOCOMPLETE.md`

### Changed

- 🔄 `ThaiAddressForm` now uses `ZipCodeAutocomplete` instead of plain TextField
- ⚡ Improved zip code input UX with real-time suggestions
- 🎨 Enhanced helper text: "ระบบจะแนะนำที่อยู่อัตโนมัติ"

### Fixed

- 🐛 Fixed issue with multiple subdistricts having same zip code
- 🔧 Improved error state handling in zip code lookup
- ✅ Clear selections properly when zip code has multiple areas

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
