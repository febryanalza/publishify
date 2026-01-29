import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/writer/naskah_models.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:logger/logger.dart';

/// Naskah Service
/// Handles all manuscript (naskah) related API calls

final Logger _logger = Logger();
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

  /// Get count of manuscripts by status from statistik endpoint
  static Future<Map<String, int>> getStatusCount() async {
    try {
      // Get token
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Call statistik endpoint
      final response = await http.get(
        Uri.parse('$baseUrl/naskah/statistik'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _logger.d('GET /naskah/statistik - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];
        final perStatus = data['perStatus'] as Map<String, dynamic>? ?? {};

        // Map backend status to frontend - return all statuses
        return {
          'draft': perStatus['draft'] ?? 0,
          'diajukan': perStatus['diajukan'] ?? 0,
          'dalam_review': perStatus['dalam_review'] ?? 0,
          'dalam_editing': perStatus['dalam_editing'] ?? 0,
          'siap_terbit': perStatus['siap_terbit'] ?? 0,
          'diterbitkan': perStatus['diterbitkan'] ?? 0,
          'ditolak': perStatus['ditolak'] ?? 0,
        };
      } else {
        _logger.e('Failed to get status count: ${response.statusCode}');
        return {
          'draft': 0,
          'diajukan': 0,
          'dalam_review': 0,
          'dalam_editing': 0,
          'siap_terbit': 0,
          'diterbitkan': 0,
          'ditolak': 0,
        };
      }
    } catch (e) {
      _logger.e('Error getting status count: $e');
      return {
        'draft': 0,
        'diajukan': 0,
        'dalam_review': 0,
        'dalam_editing': 0,
        'siap_terbit': 0,
        'diterbitkan': 0,
        'ditolak': 0,
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
    String? formatBuku,        // BARU: A4, A5, B5
    String? bahasaTulis,       // BARU: id, en, etc.
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

      // BARU: Format buku (A4, A5, B5)
      if (formatBuku != null && formatBuku.isNotEmpty) {
        body['formatBuku'] = formatBuku;
      }

      // BARU: Bahasa tulis
      if (bahasaTulis != null && bahasaTulis.isNotEmpty) {
        body['bahasaTulis'] = bahasaTulis;
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

  /// Update manuscript (naskah)
  /// PUT /api/naskah/:id
  static Future<CreateNaskahResponse> perbaruiNaskah({
    required String id,
    String? judul,
    String? subJudul,
    String? sinopsis,
    String? idKategori,
    String? idGenre,
    String? formatBuku, // A4, A5, B5
    String? bahasaTulis,
    int? jumlahHalaman,
    int? jumlahKata,
    String? urlSampul,
    String? urlFile,
    bool? publik,
    String? isbn,
    // Dokumen Kelengkapan
    String? urlSuratPerjanjian,
    String? urlSuratKeaslian,
    String? urlProposalNaskah,
    String? urlBuktiTransfer,
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

      final uri = Uri.parse('$baseUrl/api/naskah/$id');

      // Build request body - only include fields that are provided
      final Map<String, dynamic> body = {};

      if (judul != null && judul.isNotEmpty) {
        body['judul'] = judul;
      }

      if (subJudul != null) {
        body['subJudul'] = subJudul;
      }

      if (sinopsis != null && sinopsis.isNotEmpty) {
        body['sinopsis'] = sinopsis;
      }

      if (idKategori != null && idKategori.isNotEmpty) {
        body['idKategori'] = idKategori;
      }

      if (idGenre != null && idGenre.isNotEmpty) {
        body['idGenre'] = idGenre;
      }

      if (formatBuku != null && formatBuku.isNotEmpty) {
        body['formatBuku'] = formatBuku;
      }

      if (bahasaTulis != null && bahasaTulis.isNotEmpty) {
        body['bahasaTulis'] = bahasaTulis;
      }

      if (jumlahHalaman != null) {
        body['jumlahHalaman'] = jumlahHalaman;
      }

      if (jumlahKata != null) {
        body['jumlahKata'] = jumlahKata;
      }

      if (urlSampul != null) {
        body['urlSampul'] = urlSampul;
      }

      if (urlFile != null) {
        body['urlFile'] = urlFile;
      }

      if (publik != null) {
        body['publik'] = publik;
      }

      if (isbn != null && isbn.isNotEmpty) {
        body['isbn'] = isbn;
      }

      // Dokumen Kelengkapan
      if (urlSuratPerjanjian != null) {
        body['urlSuratPerjanjian'] = urlSuratPerjanjian;
      }

      if (urlSuratKeaslian != null) {
        body['urlSuratKeaslian'] = urlSuratKeaslian;
      }

      if (urlProposalNaskah != null) {
        body['urlProposalNaskah'] = urlProposalNaskah;
      }

      if (urlBuktiTransfer != null) {
        body['urlBuktiTransfer'] = urlBuktiTransfer;
      }

      // Make API request
      _logger.d('PUT /api/naskah/$id - Request body: $body');
      
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      _logger.d('PUT /api/naskah/$id - Status: ${response.statusCode}');
      _logger.d('PUT /api/naskah/$id - Response: ${response.body}');

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

  /// Ajukan naskah untuk direview oleh editor
  /// PUT /api/naskah/:id/ajukan
  /// Hanya bisa diajukan jika status draft
  static Future<CreateNaskahResponse> ajukanNaskah(String id, {String? catatan}) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return CreateNaskahResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/naskah/$id/ajukan');
      
      final body = <String, dynamic>{};
      if (catatan != null && catatan.isNotEmpty) {
        body['catatan'] = catatan;
      }

      final response = await http.put(
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
      return CreateNaskahResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ====================================
  // ENDPOINT LANJUTAN (EDITOR & PENULIS)
  // ====================================

  /// Terbitkan naskah - Hanya untuk Editor/Admin
  /// PUT /api/naskah/:id/terbitkan
  /// Hanya bisa terbitkan naskah dengan status 'siap_terbit'
  static Future<TerbitkanNaskahResponse> terbitkanNaskah(
    String id, 
    TerbitkanNaskahRequest request,
  ) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return TerbitkanNaskahResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/naskah/$id/terbitkan');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      return TerbitkanNaskahResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error terbitkan naskah: $e');
      return TerbitkanNaskahResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Ubah status naskah - Hanya untuk Editor/Admin
  /// PUT /api/naskah/:id/status
  static Future<UbahStatusNaskahResponse> ubahStatusNaskah(
    String id,
    String status,
  ) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return UbahStatusNaskahResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/naskah/$id/status');
      
      final request = UbahStatusNaskahRequest(status: status);

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      return UbahStatusNaskahResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error ubah status naskah: $e');
      return UbahStatusNaskahResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Atur harga jual naskah - Hanya untuk Penulis (owner)
  /// PUT /api/naskah/:id/harga-jual
  /// Hanya bisa untuk naskah dengan status 'diterbitkan'
  static Future<AturHargaJualResponse> aturHargaJual(
    String id,
    double hargaJual,
  ) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return AturHargaJualResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/naskah/$id/harga-jual');
      
      final request = AturHargaJualRequest(hargaJual: hargaJual);

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      return AturHargaJualResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error atur harga jual: $e');
      return AturHargaJualResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Hapus naskah - Untuk Penulis (owner) atau Admin
  /// DELETE /api/naskah/:id
  /// Penulis tidak bisa hapus naskah yang sudah diterbitkan
  static Future<HapusNaskahResponse> hapusNaskah(String id) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return HapusNaskahResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/naskah/$id');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body);
      return HapusNaskahResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error hapus naskah: $e');
      return HapusNaskahResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST /api/naskah/:id/submit-revisi
  /// Penulis submit revisi naskah dengan file baru
  static Future<SubmitRevisiResponse> submitRevisi({
    required String idNaskah,
    required String urlFileNaskah,
    String? catatan,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return SubmitRevisiResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/naskah/$idNaskah/submit-revisi');

      final body = {
        'urlFile': urlFileNaskah,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      };

      _logger.d('Submit revisi: ${uri.toString()}');
      _logger.d('Body: $body');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      _logger.d('Submit revisi response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return SubmitRevisiResponse.fromJson(responseData);
      } else {
        String errorMessage = 'Gagal submit revisi';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['pesan'] ?? errorMessage;
        } catch (e) {
          _logger.w('Error parsing error response: $e');
        }
        
        return SubmitRevisiResponse(
          sukses: false,
          pesan: errorMessage,
        );
      }
    } catch (e) {
      _logger.e('Error submit revisi: $e');
      return SubmitRevisiResponse(
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
