# Changelog

All notable changes to this project will be documented in this file.

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
