import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:publishify/models/writer/auth_models.dart';

/// Authentication Service
/// Handles all authentication related API calls
class AuthService {
  static final logger = Logger();
  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';
  
  // SharedPreferences keys
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyTokenVerifikasi = 'token_verifikasi';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';
  static const String _keyNamaDepan = 'nama_depan';
  static const String _keyNamaBelakang = 'nama_belakang';
  static const String _keyNamaTampilan = 'nama_tampilan';
  static const String _keyPeran = 'peran';
  static const String _keyTerverifikasi = 'terverifikasi';

  /// Register new user
  /// POST /api/auth/daftar
  static Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final url = Uri.parse('$baseUrl${dotenv.env['API_AUTH_DAFTAR']}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      final registerResponse = RegisterResponse.fromJson(responseData);

      // If registration successful, save to SharedPreferences
      if (registerResponse.sukses && registerResponse.data != null) {
        await _saveUserData(registerResponse.data!);
      }

      return registerResponse;
    } catch (e) {
      // Return error response
      return RegisterResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Login user
  /// POST /api/auth/login
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final url = Uri.parse('$baseUrl${dotenv.env['API_AUTH_LOGIN']}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(responseData);

      // If login successful, save to SharedPreferences
      if (loginResponse.sukses && loginResponse.data != null) {
        await _saveLoginData(loginResponse.data!);
      }

      return loginResponse;
    } catch (e) {
      // Return error response
      return LoginResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Save user data from registration to SharedPreferences
  static Future<void> _saveUserData(RegisterData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, data.id);
    await prefs.setString(_keyUserEmail, data.email);
    await prefs.setString(_keyTokenVerifikasi, data.tokenVerifikasi);
    await prefs.setBool(_keyIsLoggedIn, false); // Not logged in yet, need verification
  }

  /// Save login data to SharedPreferences
  static Future<void> _saveLoginData(LoginData data) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save tokens
    await prefs.setString(_keyAccessToken, data.accessToken);
    await prefs.setString(_keyRefreshToken, data.refreshToken);
    
    // Save user data
    await prefs.setString(_keyUserId, data.pengguna.id);
    await prefs.setString(_keyUserEmail, data.pengguna.email);
    await prefs.setStringList(_keyPeran, data.pengguna.peran);
    await prefs.setBool(_keyTerverifikasi, data.pengguna.terverifikasi);
    
    // Save profile data if available
    if (data.pengguna.profilPengguna != null) {
      final profil = data.pengguna.profilPengguna!;
      await prefs.setString(_keyNamaDepan, profil.namaDepan);
      await prefs.setString(_keyNamaBelakang, profil.namaBelakang);
      await prefs.setString(_keyNamaTampilan, profil.namaTampilan);
    }
    
    // Save complete user data as JSON for easy retrieval
    await prefs.setString(_keyUserData, jsonEncode(data.toJson()));
    
    // Mark as logged in
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Get saved user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Get saved user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Get saved token verifikasi
  static Future<String?> getTokenVerifikasi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTokenVerifikasi);
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Get complete user data from SharedPreferences
  static Future<LoginData?> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_keyUserData);
    
    if (userDataJson != null) {
      try {
        final userData = jsonDecode(userDataJson);
        return LoginData.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Get user roles using helper method from UserData
  static Future<List<String>> getUserRoles() async {
    final loginData = await getLoginData();
    if (loginData != null) {
      return loginData.pengguna.getActiveRoles();
    }
    
    // Fallback: get from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPeran) ?? [];
  }

  /// Check if user has specific role
  static Future<bool> hasRole(String role) async {
    final loginData = await getLoginData();
    if (loginData != null) {
      return loginData.pengguna.hasRole(role);
    }
    
    // Fallback: check from SharedPreferences
    final roles = await getUserRoles();
    return roles.contains(role);
  }

  /// Get primary role (first active role)
  static Future<String?> getPrimaryRole() async {
    final loginData = await getLoginData();
    if (loginData != null) {
      return loginData.pengguna.getPrimaryRole();
    }
    
    // Fallback: get first role from SharedPreferences
    final roles = await getUserRoles();
    return roles.isNotEmpty ? roles.first : null;
  }

  /// Save user roles to SharedPreferences
  static Future<void> saveUserRoles(List<String> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyPeran, roles);
  }

  /// Get nama tampilan (display name)
  static Future<String?> getNamaTampilan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNamaTampilan);
  }

  /// Check if user is verified
  static Future<bool> isVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTerverifikasi) ?? false;
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Logout user with API call
  /// POST /api/auth/logout
  static Future<bool> logout() async {
    try {
      // Get refresh token before clearing
      final refreshToken = await getRefreshToken();
      
      if (refreshToken != null) {
        try {
          final url = Uri.parse('$baseUrl${dotenv.env['API_AUTH_LOGOUT']}');
          
          // Call logout API
          await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'refreshToken': refreshToken,
            }),
          );
          
          // Regardless of API response, clear local data
        } catch (e) {
          // If API call fails, still proceed with local logout
          logger.e('Logout API error: $e');
        }
      }
      
      // Clear all local data
      await _clearAllAuthData();
      return true;
    } catch (e) {
      // Even if error, try to clear local data
      logger.e('Logout error: $e');
      await _clearAllAuthData();
      return false;
    }
  }

  /// Clear all saved auth data from SharedPreferences
  static Future<void> _clearAllAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all auth related data
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyTokenVerifikasi);
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserData);
    await prefs.remove(_keyNamaDepan);
    await prefs.remove(_keyNamaBelakang);
    await prefs.remove(_keyNamaTampilan);
    await prefs.remove(_keyPeran);
    await prefs.remove(_keyTerverifikasi);
    await prefs.remove(_keyIsLoggedIn);
    
    // Also clear any other profile related data
    await prefs.remove('bio');
    await prefs.remove('url_avatar');
    await prefs.remove('tanggal_lahir');
    await prefs.remove('jenis_kelamin');
    await prefs.remove('alamat');
    await prefs.remove('kota');
    await prefs.remove('provinsi');
    await prefs.remove('kode_pos');
    await prefs.remove('telepon');
  }

  /// Clear all data including verification token
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ====================================
  // ENHANCED ROLE MANAGEMENT METHODS
  // ====================================
  // Methods updated to use UserData helper methods

}
