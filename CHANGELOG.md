# Changelog

All notable changes to this project will be documented in this file.

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
