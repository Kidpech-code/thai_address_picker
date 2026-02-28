/// Thai Address Picker Library
///
/// A comprehensive library for selecting Thai addresses including:
/// - Provinces, Districts, Sub-districts
/// - Villages with Moo number support
/// - Zip codes with auto-complete and reverse lookup
library;

// Models
export 'src/models/geography.dart';
export 'src/models/province.dart';
export 'src/models/district.dart';
export 'src/models/sub_district.dart';
export 'src/models/village.dart';
export 'src/models/thai_address.dart';
export 'src/models/thai_address_labels.dart';
export 'src/models/suggestions.dart';

// Contracts (abstract interface for DI / mocking / alternative data sources)
export 'src/contracts/i_thai_address_repository.dart';

// Repository (default JSON-asset implementation)
export 'src/repository/thai_address_repository.dart';

// Controller (ValueNotifier-based state management — no Riverpod required)
export 'src/controllers/thai_address_controller.dart';

// Widgets (pure Flutter — no Riverpod required)
export 'src/widgets/thai_address_form.dart';
export 'src/widgets/thai_address_picker.dart';
export 'src/widgets/zip_code_autocomplete.dart';
export 'src/widgets/village_autocomplete.dart';

// Optional Riverpod integration layer — uncomment if you use flutter_riverpod
// export 'src/providers/thai_address_providers.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Enterprise Architecture v2 — High-Performance Engine
// ═══════════════════════════════════════════════════════════════════════════

// Core — Exceptions & error boundaries
export 'src/core/exceptions.dart';

// Models v2 — Memory-optimized flat structures
export 'src/models/address_entry.dart';
export 'src/models/village_entry.dart';
export 'src/models/search_result.dart';

// Contracts v2 — Clean repository interface for search engine
export 'src/contracts/i_address_repository.dart';

// Search Engine — Trigram-based O(1) lookup with LRU caching
export 'src/engine/thai_address_search_engine.dart';
export 'src/engine/trigram_index.dart';
export 'src/engine/query_parser.dart';
export 'src/engine/lru_cache.dart';
