import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:publishify/models/writer/update_profile_models.dart';
import 'package:publishify/models/writer/profile_api_models.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Editor Profile Service
/// Handles editor profile related API calls
class EditorProfileService {
  static final logger = Logger();

  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:3000';
  
  // Cache expiry time (in hours)
  static const int cacheExpiryHours = 1;

  /// Get editor profile from API or cache
  /// GET /api/pengguna/profil/saya
  static Future<ProfileApiResponse> getProfile({bool forceRefresh = false}) async {
    try {
      // Check cache first if not forced refresh
      if (!forceRefresh) {
        final cachedProfile = await _getProfileFromCache();
        if (cachedProfile != null) {
          return ProfileApiResponse(
            sukses: true,
            pesan: 'Profil berhasil diambil dari cache',
            data: cachedProfile,
          );
        }
      }

      // Get access token
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return ProfileApiResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pengguna/profil/saya');

      // Make API request
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body);
      final profileResponse = ProfileApiResponse.fromJson(responseData);

      // If successful, save to cache
      if (profileResponse.sukses && profileResponse.data != null) {
        await _saveProfileToCache(profileResponse.data!);
      }

      return profileResponse;
    } catch (e) {
      // Return error response
      return ProfileApiResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Get profile from cache if not expired
  static Future<ProfileUserData?> _getProfileFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if cache exists and not expired
      final cacheTime = prefs.getInt('editor_profile_cache_time');
      if (cacheTime == null) return null;
      
      final cacheDateTime = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      final now = DateTime.now();
      final difference = now.difference(cacheDateTime).inHours;
      
      // If cache expired, return null
      if (difference >= cacheExpiryHours) {
        return null;
      }
      
      // Get cached profile data
      final profileJson = prefs.getString('editor_profile_data');
      if (profileJson == null) return null;
      
      final profileData = jsonDecode(profileJson);
      return ProfileUserData.fromJson(profileData);
    } catch (e) {
      logger.e('Error getting profile from cache: $e');
      return null;
    }
  }

  /// Save profile to cache
  static Future<void> _saveProfileToCache(ProfileUserData profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save profile data
      final profileJson = jsonEncode(profile.toJson());
      await prefs.setString('editor_profile_data', profileJson);
      
      // Save cache time
      await prefs.setInt('editor_profile_cache_time', DateTime.now().millisecondsSinceEpoch);
      
      logger.i('Profile saved to cache successfully');
    } catch (e) {
      logger.e('Error saving profile to cache: $e');
    }
  }

  /// Clear profile cache
  static Future<void> clearProfileCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('editor_profile_data');
      await prefs.remove('editor_profile_cache_time');
      logger.i('Profile cache cleared');
    } catch (e) {
      logger.e('Error clearing profile cache: $e');
    }
  }

  /// Update profile
  /// PUT /api/pengguna/profil
  static Future<UpdateProfileResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      // Get access token
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return UpdateProfileResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pengguna/profil');

      // Make API request
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      logger.i('Update profile response status: ${response.statusCode}');
      logger.i('Update profile response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final updateResponse = UpdateProfileResponse.fromJson(responseData);

      // If successful, clear cache to force refresh
      if (updateResponse.sukses) {
        await clearProfileCache();
      }

      return updateResponse;
    } catch (e) {
      logger.e('Error updating profile: $e');
      return UpdateProfileResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Update telepon
  /// PUT /api/pengguna/telepon
  static Future<UpdateProfileResponse> updateTelepon(String telepon) async {
    try {
      // Get access token
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return UpdateProfileResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pengguna/telepon');

      // Make API request
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'telepon': telepon}),
      );

      logger.i('Update telepon response status: ${response.statusCode}');
      logger.i('Update telepon response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final updateResponse = UpdateProfileResponse.fromJson(responseData);

      // If successful, clear cache to force refresh
      if (updateResponse.sukses) {
        await clearProfileCache();
      }

      return updateResponse;
    } catch (e) {
      logger.e('Error updating telepon: $e');
      return UpdateProfileResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
