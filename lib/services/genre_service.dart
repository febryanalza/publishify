import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/genre_models.dart';
import 'package:publishify/services/auth_service.dart';

/// Genre Service
/// Handles all genre related API calls
class GenreService {
  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Get list of genres with pagination
  /// GET /api/genre?halaman=1&limit=20&aktif=true
  static Future<GenreResponse> getGenres({
    int halaman = 1,
    int limit = 20,
    bool? aktif,
  }) async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return GenreResponse(
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

      final uri = Uri.parse('$baseUrl/api/genre')
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
      return GenreResponse.fromJson(responseData);
    } catch (e) {
      // Return error response
      return GenreResponse(
        sukses: false,
      );
    }
  }

  /// Get only active genres
  /// GET /api/genre/aktif
  static Future<GenreResponse> getActiveGenres() async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return GenreResponse(
          sukses: false,
        );
      }

      final uri = Uri.parse('$baseUrl/api/genre/aktif');

      // Make API request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body);
      return GenreResponse.fromJson(responseData);
    } catch (e) {
      // Return error response
      return GenreResponse(
        sukses: false,
      );
    }
  }
}
