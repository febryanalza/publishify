import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/writer/naskah_models.dart';
import 'package:publishify/services/general/auth_service.dart';

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

  /// Get user's manuscripts with specific status
  /// GET /api/naskah/penulis/saya?status=diterbitkan&halaman=1&limit=100
  static Future<List<NaskahData>> getNaskahPenulisWithStatus(String status) async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      // Build URL with query parameters for getting all manuscripts with status
      final queryParams = {
        'status': status,
        'halaman': '1',
        'limit': '100', // Get a large number to get all manuscripts
      };

      final uri = Uri.parse('$baseUrl/api/naskah/penulis/saya')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final naskahResponse = NaskahListResponse.fromJson(responseData);
        
        if (naskahResponse.sukses && naskahResponse.data != null) {
          return naskahResponse.data!;
        } else {
          throw Exception(naskahResponse.pesan);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// GET /api/naskah/:id - Detail naskah
  static Future<NaskahDetailResponse> ambilDetailNaskah(String id) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        throw Exception('Token akses tidak ditemukan');
      }

      final url = Uri.parse('$baseUrl/api/naskah/$id');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return NaskahDetailResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['pesan'] ?? 'Gagal mengambil detail naskah');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get published manuscripts (latest 10) - PUBLIC endpoint
  /// GET /api/naskah?status=diterbitkan&limit=10&urutkan=dibuatPada&arah=desc
  static Future<NaskahListResponse> getNaskahTerbit({
    int limit = 10,
  }) async {
    try {
      // Build URL with query parameters
      final queryParams = {
        'status': 'diterbitkan',
        'limit': limit.toString(),
        'urutkan': 'dibuatPada',
        'arah': 'desc',
        'halaman': '1',
      };

      final uri = Uri.parse('$baseUrl/api/naskah')
          .replace(queryParameters: queryParams);

      // Make API request (PUBLIC, no auth required)
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
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

  /// Create new manuscript (naskah)
  /// POST /api/naskah
  static Future<CreateNaskahResponse> createNaskah({
    required String judul,
    String? subJudul,
    required String sinopsis,
    required String idKategori,
    required String idGenre,
    String? isbn,
    int? jumlahHalaman,
    int? jumlahKata,
    String? urlSampul,
    String? urlFile,
    bool publik = false,
  }) async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return CreateNaskahResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/naskah');

      // Build request body
      final Map<String, dynamic> body = {
        'judul': judul,
        'sinopsis': sinopsis,
        'idKategori': idKategori,
        'idGenre': idGenre,
        'publik': publik,
      };

      if (subJudul != null && subJudul.isNotEmpty) {
        body['subJudul'] = subJudul;
      }

      if (isbn != null && isbn.isNotEmpty) {
        body['isbn'] = isbn;
      }

      if (jumlahHalaman != null) {
        body['jumlahHalaman'] = jumlahHalaman;
      }

      if (jumlahKata != null) {
        body['jumlahKata'] = jumlahKata;
      }

      if (urlSampul != null && urlSampul.isNotEmpty) {
        body['urlSampul'] = urlSampul;
      }

      if (urlFile != null && urlFile.isNotEmpty) {
        body['urlFile'] = urlFile;
      }

      // Make API request
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      return CreateNaskahResponse.fromJson(responseData);
    } catch (e) {
      // Return error response
      return CreateNaskahResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Get all manuscripts with full options (for list page)
  /// GET /api/naskah/penulis/saya
  static Future<NaskahListResponse> getAllNaskah({
    int halaman = 1,
    int limit = 20,
    String? cari,
    String? status,
    String? idKategori,
    String? idGenre,
    String urutkan = 'dibuatPada',  // dibuatPada, judul, status, jumlahHalaman
    String arah = 'desc',  // asc, desc
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
        'urutkan': urutkan,
        'arah': arah,
      };
      
      if (cari != null && cari.isNotEmpty) {
        queryParams['cari'] = cari;
      }
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (idKategori != null && idKategori.isNotEmpty) {
        queryParams['idKategori'] = idKategori;
      }
      
      if (idGenre != null && idGenre.isNotEmpty) {
        queryParams['idGenre'] = idGenre;
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
}

/// Response for creating naskah
class CreateNaskahResponse {
  final bool sukses;
  final String pesan;
  final NaskahData? data;

  CreateNaskahResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory CreateNaskahResponse.fromJson(Map<String, dynamic> json) {
    return CreateNaskahResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? NaskahData.fromJson(json['data']) : null,
    );
  }
}
