import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/writer/kategori_models.dart';
import 'package:publishify/services/writer/auth_service.dart';

/// Kategori Service
/// Handles all kategori related API calls
class KategoriService {
  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Get list of kategori with pagination
  /// GET /api/kategori?halaman=1&limit=20&aktif=true
  static Future<KategoriResponse> getKategori({
    int halaman = 1,
    int limit = 20,
    bool? aktif,
  }) async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return KategoriResponse(
          sukses: false,
        );
      }

      // Build URL with query parameters
      final queryParams = {
        'halaman': halaman.toString(),
        'limit': limit.toString(),
      };
      
      if (aktif != null) {
        queryParams['aktif'] = aktif.toString();
      }

      final uri = Uri.parse('$baseUrl/api/kategori')
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
      return KategoriResponse.fromJson(responseData);
    } catch (e) {
      // Return error response
      return KategoriResponse(
        sukses: false,
      );
    }
  }

  /// Get only active kategori
  /// GET /api/kategori/aktif
  static Future<KategoriResponse> getActiveKategori() async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return KategoriResponse(
          sukses: false,
        );
      }

      final uri = Uri.parse('$baseUrl/api/kategori/aktif');

      // Make API request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body);
      return KategoriResponse.fromJson(responseData);
    } catch (e) {
      // Return error response
      return KategoriResponse(
        sukses: false,
      );
    }
  }
}
