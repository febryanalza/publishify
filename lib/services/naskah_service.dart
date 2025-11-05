import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/naskah_models.dart';
import 'package:publishify/services/auth_service.dart';

/// Naskah Service
/// Handles all manuscript (naskah) related API calls
class NaskahService {
  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Get list of user's manuscripts (naskah penulis saya)
  /// GET /api/naskah/penulis/saya?halaman=1&limit=6&status=draft
  static Future<NaskahListResponse> getNaskahSaya({
    int halaman = 1,
    int limit = 6,
    String? status,
  }) async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return NaskahListResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      // Build URL with query parameters
      final queryParams = {
        'halaman': halaman.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/api/naskah/penulis/saya')
          .replace(queryParameters: queryParams);

      // Make API request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body);
      return NaskahListResponse.fromJson(responseData);
    } catch (e) {
      // Return error response
      return NaskahListResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Get count of manuscripts by status
  static Future<Map<String, int>> getStatusCount() async {
    try {
      final response = await getNaskahSaya(limit: 100); // Get all to count
      
      if (!response.sukses || response.data == null) {
        return {
          'draft': 0,
          'review': 0,
          'revision': 0,
          'published': 0,
        };
      }

      // Count by status
      final Map<String, int> statusCount = {
        'draft': 0,
        'review': 0,
        'revision': 0,
        'published': 0,
      };

      for (var naskah in response.data!) {
        final status = naskah.status.toLowerCase();
        if (statusCount.containsKey(status)) {
          statusCount[status] = statusCount[status]! + 1;
        }
      }

      return statusCount;
    } catch (e) {
      return {
        'draft': 0,
        'review': 0,
        'revision': 0,
        'published': 0,
      };
    }
  }
}
