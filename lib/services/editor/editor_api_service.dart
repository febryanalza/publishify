/// Editor API Service - HTTP Client Layer
/// Centralized API service untuk semua endpoint editor/review
/// Best Practice: Single responsibility, proper error handling, authentication

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/models/editor/review_models.dart';

/// Logger untuk debugging
final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

/// Base API Response class untuk handling response
class ApiResponse<T> {
  final bool sukses;
  final String pesan;
  final T? data;
  final Map<String, dynamic>? metadata;
  final int? statusCode;

  ApiResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String pesan = 'Sukses', Map<String, dynamic>? metadata}) {
    return ApiResponse(sukses: true, pesan: pesan, data: data, metadata: metadata);
  }

  factory ApiResponse.error(String pesan, {int? statusCode}) {
    return ApiResponse(sukses: false, pesan: pesan, statusCode: statusCode);
  }
}

/// Editor API Service - Core HTTP Client
class EditorApiService {
  // Singleton pattern untuk efficiency
  static final EditorApiService _instance = EditorApiService._internal();
  factory EditorApiService() => _instance;
  EditorApiService._internal();

  /// Base URL dari .env atau default
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:3000';
  
  /// Review API base path
  static const String reviewPath = '/api/review';
  
  /// Timeout duration
  static const Duration timeout = Duration(seconds: 30);

  /// Get authorization headers dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Generic GET request handler
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
      );
      
      _logger.d('GET: $uri');
      
      final response = await http.get(uri, headers: headers).timeout(timeout);
      
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Kesalahan jaringan: ${e.message}');
    } catch (e) {
      _logger.e('GET Error: $e');
      return ApiResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Generic POST request handler
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      
      _logger.d('POST: $uri');
      _logger.d('Body: $body');
      
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(timeout);
      
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Kesalahan jaringan: ${e.message}');
    } catch (e) {
      _logger.e('POST Error: $e');
      return ApiResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Generic PUT request handler
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      
      _logger.d('PUT: $uri');
      _logger.d('Body: $body');
      
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(timeout);
      
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Kesalahan jaringan: ${e.message}');
    } catch (e) {
      _logger.e('PUT Error: $e');
      return ApiResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Generic DELETE request handler
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      
      _logger.d('DELETE: $uri');
      
      final request = http.Request('DELETE', uri)
        ..headers.addAll(headers);
      
      if (body != null) {
        request.body = json.encode(body);
      }
      
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Kesalahan jaringan: ${e.message}');
    } catch (e) {
      _logger.e('DELETE Error: $e');
      return ApiResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Handle HTTP response dan convert ke ApiResponse
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    _logger.d('Response Status: ${response.statusCode}');
    _logger.d('Response Body: ${response.body}');
    
    try {
      final Map<String, dynamic> body = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          sukses: body['sukses'] ?? true,
          pesan: body['pesan'] ?? 'Sukses',
          data: body['data'] != null && fromJson != null 
              ? fromJson(body['data']) 
              : body['data'] as T?,
          metadata: body['metadata'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<T>(
          sukses: false,
          pesan: body['pesan'] ?? _getErrorMessage(response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.e('Parse Response Error: $e');
      return ApiResponse<T>(
        sukses: false,
        pesan: 'Gagal memproses response dari server',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get error message berdasarkan status code
  static String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid';
      case 401:
        return 'Sesi telah berakhir. Silakan login kembali';
      case 403:
        return 'Anda tidak memiliki akses untuk fitur ini';
      case 404:
        return 'Data tidak ditemukan';
      case 409:
        return 'Data sudah ada atau konflik';
      case 422:
        return 'Data yang dikirim tidak valid';
      case 500:
        return 'Terjadi kesalahan pada server';
      default:
        return 'Terjadi kesalahan (Kode: $statusCode)';
    }
  }

  // =====================================================
  // REVIEW ENDPOINTS
  // =====================================================

  /// POST /review/tugaskan - Tugaskan review ke editor
  static Future<ApiResponse<ReviewNaskah>> tugaskanReview(
    TugaskanReviewRequest request,
  ) async {
    return post<ReviewNaskah>(
      '$reviewPath/tugaskan',
      body: request.toJson(),
      fromJson: (data) => ReviewNaskah.fromJson(data),
    );
  }

  /// GET /review - Ambil semua review dengan filter
  static Future<ApiResponse<List<ReviewNaskah>>> ambilSemuaReview({
    FilterReview? filter,
  }) async {
    return get<List<ReviewNaskah>>(
      reviewPath,
      queryParams: filter?.toQueryParams(),
      fromJson: (data) => (data as List).map((e) => ReviewNaskah.fromJson(e)).toList(),
    );
  }

  /// GET /review/statistik - Ambil statistik review
  static Future<ApiResponse<StatistikReview>> ambilStatistikReview({
    String? idEditor,
  }) async {
    return get<StatistikReview>(
      '$reviewPath/statistik',
      queryParams: idEditor != null ? {'idEditor': idEditor} : null,
      fromJson: (data) => StatistikReview.fromJson(data),
    );
  }

  /// GET /review/editor/saya - Ambil review milik editor yang login
  static Future<ApiResponse<List<ReviewNaskah>>> ambilReviewSaya({
    FilterReview? filter,
  }) async {
    return get<List<ReviewNaskah>>(
      '$reviewPath/editor/saya',
      queryParams: filter?.toQueryParams(),
      fromJson: (data) => (data as List).map((e) => ReviewNaskah.fromJson(e)).toList(),
    );
  }

  /// GET /review/naskah/:idNaskah - Ambil review untuk naskah tertentu
  static Future<ApiResponse<List<ReviewNaskah>>> ambilReviewNaskah(
    String idNaskah, {
    FilterReview? filter,
  }) async {
    return get<List<ReviewNaskah>>(
      '$reviewPath/naskah/$idNaskah',
      queryParams: filter?.toQueryParams(),
      fromJson: (data) => (data as List).map((e) => ReviewNaskah.fromJson(e)).toList(),
    );
  }

  /// GET /review/:id - Ambil detail review by ID
  static Future<ApiResponse<ReviewNaskah>> ambilReviewById(String id) async {
    return get<ReviewNaskah>(
      '$reviewPath/$id',
      fromJson: (data) => ReviewNaskah.fromJson(data),
    );
  }

  /// PUT /review/:id - Perbarui review
  static Future<ApiResponse<ReviewNaskah>> perbaruiReview(
    String id,
    PerbaruiReviewRequest request,
  ) async {
    return put<ReviewNaskah>(
      '$reviewPath/$id',
      body: request.toJson(),
      fromJson: (data) => ReviewNaskah.fromJson(data),
    );
  }

  /// POST /review/:id/feedback - Tambah feedback ke review
  static Future<ApiResponse<FeedbackReview>> tambahFeedback(
    String idReview,
    TambahFeedbackRequest request,
  ) async {
    return post<FeedbackReview>(
      '$reviewPath/$idReview/feedback',
      body: request.toJson(),
      fromJson: (data) => FeedbackReview.fromJson(data),
    );
  }

  /// PUT /review/:id/submit - Submit/finalisasi review
  static Future<ApiResponse<ReviewNaskah>> submitReview(
    String id,
    SubmitReviewRequest request,
  ) async {
    return put<ReviewNaskah>(
      '$reviewPath/$id/submit',
      body: request.toJson(),
      fromJson: (data) => ReviewNaskah.fromJson(data),
    );
  }

  /// PUT /review/:id/batal - Batalkan review
  static Future<ApiResponse<ReviewNaskah>> batalkanReview(
    String id,
    String alasan,
  ) async {
    return put<ReviewNaskah>(
      '$reviewPath/$id/batal',
      body: {'alasan': alasan},
      fromJson: (data) => ReviewNaskah.fromJson(data),
    );
  }

  // =====================================================
  // EDITOR MANAGEMENT
  // =====================================================

  // =====================================================
  // NASKAH MASUK (untuk editor)
  // =====================================================

  /// GET /naskah - Ambil naskah dengan status 'diajukan' yang belum direview
  /// Untuk halaman Naskah Masuk editor
  static Future<ApiResponse<List<Map<String, dynamic>>>> ambilNaskahMasuk({
    int halaman = 1,
    int limit = 20,
  }) async {
    return get<List<Map<String, dynamic>>>(
      '/api/naskah',
      queryParams: {
        'status': 'diajukan',
        'halaman': halaman.toString(),
        'limit': limit.toString(),
        'urutkan': 'dibuatPada',
        'arah': 'desc',
      },
      fromJson: (data) {
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  /// GET /pengguna/editor - Ambil daftar editor yang tersedia
  static Future<ApiResponse<List<Map<String, dynamic>>>> ambilDaftarEditor() async {
    try {
      // Endpoint untuk daftar editor (jika tersedia di backend)
      // Jika tidak ada, gunakan placeholder
      return get<List<Map<String, dynamic>>>(
        '/api/pengguna/editor',
        fromJson: (data) {
          if (data is List) {
            return data.cast<Map<String, dynamic>>();
          }
          return <Map<String, dynamic>>[];
        },
      );
    } catch (e) {
      // Return empty list sebagai fallback
      _logger.w('ambilDaftarEditor fallback: $e');
      return ApiResponse.success(<Map<String, dynamic>>[], pesan: 'Daftar editor kosong');
    }
  }
}
