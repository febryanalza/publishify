import 'dart:convert';
import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/update_profile_models.dart';
import 'package:publishify/models/profile_api_models.dart';
import 'package:publishify/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profile Service
/// Handles profile related API calls
class ProfileService {
  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';
  
  // Cache expiry time (in hours)
  static const int cacheExpiryHours = 1;

  /// Get user profile from API or cache
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
      final cacheTime = prefs.getInt('profile_cache_time');
      if (cacheTime == null) return null;
      
      final cacheDateTime = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      final now = DateTime.now();
      final difference = now.difference(cacheDateTime).inHours;
      
      // If cache expired, return null
      if (difference >= cacheExpiryHours) {
        return null;
      }
      
      // Get cached profile data
      final profileJson = prefs.getString('profile_data');
      if (profileJson == null) return null;
      
      final profileData = jsonDecode(profileJson);
      return ProfileUserData.fromJson(profileData);
    } catch (e) {
      return null;
    }
  }

  /// Save profile to cache
  static Future<void> _saveProfileToCache(ProfileUserData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save profile data as JSON
      await prefs.setString('profile_data', jsonEncode(data.toJson()));
      
      // Save cache timestamp
      await prefs.setInt('profile_cache_time', DateTime.now().millisecondsSinceEpoch);
      
      // Also save individual fields for backward compatibility
      await prefs.setString('email', data.email);
      if (data.telepon != null) {
        await prefs.setString('telepon', data.telepon!);
      }
      
      if (data.profilPengguna != null) {
        final profil = data.profilPengguna!;
        await prefs.setString('nama_depan', profil.namaDepan);
        await prefs.setString('nama_belakang', profil.namaBelakang);
        await prefs.setString('nama_tampilan', profil.namaTampilan);
        
        if (profil.bio != null) {
          await prefs.setString('bio', profil.bio!);
        }
        if (profil.urlAvatar != null) {
          await prefs.setString('url_avatar', profil.urlAvatar!);
        }
        if (profil.alamat != null) {
          await prefs.setString('alamat', profil.alamat!);
        }
        if (profil.kota != null) {
          await prefs.setString('kota', profil.kota!);
        }
        if (profil.provinsi != null) {
          await prefs.setString('provinsi', profil.provinsi!);
        }
        if (profil.kodePos != null) {
          await prefs.setString('kode_pos', profil.kodePos!);
        }
      }
      
      // Save roles
      if (data.peranPengguna.isNotEmpty) {
        final roles = data.peranPengguna
            .where((role) => role.aktif)
            .map((role) => role.jenisPeran)
            .toList();
        await prefs.setString('roles', jsonEncode(roles));
      }
    } catch (e) {
      printToConsole('Error saving profile to cache: $e');
    }
  }

  /// Clear profile cache
  static Future<void> clearProfileCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_data');
      await prefs.remove('profile_cache_time');
    } catch (e) {
      printToConsole('Error clearing profile cache: $e');
    }
  }

  /// Update user profile
  /// PUT /api/pengguna/profil/saya
  static Future<UpdateProfileResponse> updateProfile(
    UpdateProfileRequest request,
  ) async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return UpdateProfileResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pengguna/profil/saya');

      // Make API request
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      final updateResponse = UpdateProfileResponse.fromJson(responseData);

      // If update successful, update cache
      if (updateResponse.sukses && updateResponse.data != null) {
        await _updateCache(updateResponse.data!);
      }

      return updateResponse;
    } catch (e) {
      // Return error response
      return UpdateProfileResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Update cached user data after successful profile update
  static Future<void> _updateCache(UpdatedUserData data) async {
    final prefs = await SharedPreferences.getInstance();

    // Update telepon if provided
    if (data.telepon != null) {
      await prefs.setString('telepon', data.telepon!);
    }

    // Update profile data if available
    if (data.profilPengguna != null) {
      final profil = data.profilPengguna!;
      
      await prefs.setString('nama_depan', profil.namaDepan);
      await prefs.setString('nama_belakang', profil.namaBelakang);
      await prefs.setString('nama_tampilan', profil.namaTampilan);
      
      if (profil.bio != null) {
        await prefs.setString('bio', profil.bio!);
      }
      
      if (profil.urlAvatar != null) {
        await prefs.setString('url_avatar', profil.urlAvatar!);
      }
      
      if (profil.tanggalLahir != null) {
        await prefs.setString('tanggal_lahir', profil.tanggalLahir!);
      }
      
      if (profil.jenisKelamin != null) {
        await prefs.setString('jenis_kelamin', profil.jenisKelamin!);
      }
      
      if (profil.alamat != null) {
        await prefs.setString('alamat', profil.alamat!);
      }
      
      if (profil.kota != null) {
        await prefs.setString('kota', profil.kota!);
      }
      
      if (profil.provinsi != null) {
        await prefs.setString('provinsi', profil.provinsi!);
      }
      
      if (profil.kodePos != null) {
        await prefs.setString('kode_pos', profil.kodePos!);
      }
    }

    // Update complete user_data JSON
    try {
      final userDataJson = prefs.getString('user_data');
      if (userDataJson != null) {
        final userData = jsonDecode(userDataJson);
        
        // Update user data with new values
        if (data.telepon != null) {
          userData['pengguna']['telepon'] = data.telepon;
        }
        
        if (data.profilPengguna != null) {
          userData['pengguna']['profilPengguna'] = {
            'id': data.profilPengguna!.id,
            'namaDepan': data.profilPengguna!.namaDepan,
            'namaBelakang': data.profilPengguna!.namaBelakang,
            'namaTampilan': data.profilPengguna!.namaTampilan,
            'bio': data.profilPengguna!.bio,
            'urlAvatar': data.profilPengguna!.urlAvatar,
            'tanggalLahir': data.profilPengguna!.tanggalLahir,
            'jenisKelamin': data.profilPengguna!.jenisKelamin,
            'alamat': data.profilPengguna!.alamat,
            'kota': data.profilPengguna!.kota,
            'provinsi': data.profilPengguna!.provinsi,
            'kodePos': data.profilPengguna!.kodePos,
            'diperbaruiPada': data.profilPengguna!.diperbaruiPada,
          };
        }
        
        await prefs.setString('user_data', jsonEncode(userData));
      }
    } catch (e) {
      // If error updating user_data, continue anyway
      printToConsole('Error updating user_data cache: $e');
    }
  }
}
