/// Editor Services Export
/// File ini mengexport semua service editor untuk kemudahan import
/// 
/// Penggunaan:
/// ```dart
/// import 'package:publishify/services/editor/editor_exports.dart';
/// ```

// API Layer - Core HTTP client
export 'editor_api_service.dart';

// Business Logic Layer - Main service
export 'editor_service.dart';

// Unified Review Service - RECOMMENDED (consolidated with caching)
export 'unified_review_service.dart';

// Review Workflow Layer - Review lifecycle management
export 'editor_review_service.dart';

// Statistics Layer - Dashboard metrics
export 'statistik_service.dart';

// Legacy Services (deprecated - use UnifiedReviewService instead)
// Naskah Submission Layer - Naskah submissions review
export 'review_naskah_service.dart';

// Review Collection Layer - Buku masuk review
export 'review_collection_service.dart';

// Models - All review-related models
export 'package:publishify/models/editor/review_models.dart';
export 'package:publishify/models/editor/review_naskah_models.dart';
export 'package:publishify/models/editor/review_collection_models.dart';
export 'package:publishify/models/editor/editor_models.dart';
