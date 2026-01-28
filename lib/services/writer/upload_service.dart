import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/models/writer/upload_models.dart';
import 'package:mime/mime.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

/// Upload Service
/// Handles file upload to backend
class UploadService {
  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Upload single file (naskah)
  /// POST /api/upload/single
  static Future<UploadResponse> uploadNaskah({
    required File file,
    String? deskripsi,
    String? idReferensi,
  }) async {
    try {
      // Get access token
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return UploadResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      // Create multipart request
      final uri = Uri.parse('$baseUrl/api/upload/single');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Add file
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final mimeTypeData = mimeType.split('/');
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      // Add form fields
      request.fields['tujuan'] = 'naskah';
      
      if (deskripsi != null && deskripsi.isNotEmpty) {
        request.fields['deskripsi'] = deskripsi;
      }
      
      if (idReferensi != null && idReferensi.isNotEmpty) {
        request.fields['idReferensi'] = idReferensi;
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return UploadResponse.fromJson(responseData);
      } else {
        return UploadResponse(
          sukses: false,
          pesan: responseData['pesan'] ?? 'Upload gagal',
        );
      }
    } catch (e) {
      return UploadResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Upload sampul buku
  /// POST /api/upload/single
  static Future<UploadResponse> uploadSampul({
    required File file,
    String? deskripsi,
    String? idReferensi,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return UploadResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/upload/single');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $accessToken';

      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final mimeTypeData = mimeType.split('/');
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      request.fields['tujuan'] = 'sampul';
      
      if (deskripsi != null && deskripsi.isNotEmpty) {
        request.fields['deskripsi'] = deskripsi;
      }
      
      if (idReferensi != null && idReferensi.isNotEmpty) {
        request.fields['idReferensi'] = idReferensi;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return UploadResponse.fromJson(responseData);
      } else {
        return UploadResponse(
          sukses: false,
          pesan: responseData['pesan'] ?? 'Upload gagal',
        );
      }
    } catch (e) {
      return UploadResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Upload dokumen pendukung (surat perjanjian, surat keaslian, proposal, dll)
  /// POST /api/upload/single dengan tujuan = 'dokumen'
  static Future<UploadResponse> uploadDokumen({
    required File file,
    String? deskripsi,
    String? idReferensi,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return UploadResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/upload/single');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $accessToken';

      final mimeType = lookupMimeType(file.path) ?? 'application/pdf';
      final mimeTypeData = mimeType.split('/');
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      // Gunakan tujuan 'dokumen' untuk dokumen pendukung
      request.fields['tujuan'] = 'dokumen';
      
      if (deskripsi != null && deskripsi.isNotEmpty) {
        request.fields['deskripsi'] = deskripsi;
      }
      
      if (idReferensi != null && idReferensi.isNotEmpty) {
        request.fields['idReferensi'] = idReferensi;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return UploadResponse.fromJson(responseData);
      } else {
        return UploadResponse(
          sukses: false,
          pesan: responseData['pesan'] ?? 'Upload gagal',
        );
      }
    } catch (e) {
      return UploadResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ==========================================
  // NEW ENDPOINTS
  // ==========================================

  /// Upload multiple files
  /// POST /api/upload/multiple
  static Future<UploadMultipleResponse> uploadMultiple({
    required List<File> files,
    required String tujuan,
    String? deskripsi,
    String? idReferensi,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return UploadMultipleResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
          berhasil: [],
          gagal: [],
          totalBerhasil: 0,
          totalGagal: 0,
        );
      }

      final uri = Uri.parse('$baseUrl/api/upload/multiple');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['tujuan'] = tujuan;

      if (deskripsi != null && deskripsi.isNotEmpty) {
        request.fields['deskripsi'] = deskripsi;
      }
      if (idReferensi != null && idReferensi.isNotEmpty) {
        request.fields['idReferensi'] = idReferensi;
      }

      // Add all files
      for (final file in files) {
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        final mimeTypeData = mimeType.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logger.d('Upload multiple response: ${response.statusCode}');

      final responseData = jsonDecode(response.body);
      return UploadMultipleResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error uploading multiple files: $e');
      return UploadMultipleResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
        berhasil: [],
        gagal: [],
        totalBerhasil: 0,
        totalGagal: 0,
      );
    }
  }

  /// Get list of user's files with pagination and filter
  /// GET /api/upload
  static Future<DaftarFileResponse> getDaftarFile({
    int halaman = 1,
    int limit = 20,
    String? tujuan,
    String? cari,
    String? urutkan,
    String? arah,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return DaftarFileResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
          data: [],
        );
      }

      final queryParams = <String, String>{
        'halaman': halaman.toString(),
        'limit': limit.toString(),
      };
      if (tujuan != null && tujuan.isNotEmpty) queryParams['tujuan'] = tujuan;
      if (cari != null && cari.isNotEmpty) queryParams['cari'] = cari;
      if (urutkan != null) queryParams['urutkan'] = urutkan;
      if (arah != null) queryParams['arah'] = arah;

      final uri = Uri.parse('$baseUrl/api/upload')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      _logger.d('Get daftar file response: ${response.statusCode}');

      if (response.statusCode != 200) {
        _logger.e('Get daftar file error body: ${response.body}');
        
        // Coba parse error message dari backend
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['pesan'] ?? errorData['message'] ?? 'Gagal memuat daftar file';
          return DaftarFileResponse(
            sukses: false,
            pesan: '$errorMessage (${response.statusCode})',
            data: [],
          );
        } catch (e) {
          return DaftarFileResponse(
            sukses: false,
            pesan: 'Gagal memuat daftar file (${response.statusCode})',
            data: [],
          );
        }
      }

      final responseData = jsonDecode(response.body);
      return DaftarFileResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error getting file list: $e');
      return DaftarFileResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
        data: [],
      );
    }
  }

  /// Get file URL by ID
  /// GET /api/upload/:id
  static Future<FileUrlResponse> getFileUrl(String fileId) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return FileUrlResponse(sukses: false, url: '');
      }

      final uri = Uri.parse('$baseUrl/api/upload/$fileId');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      _logger.d('Get file URL response: ${response.statusCode}');

      final responseData = jsonDecode(response.body);
      return FileUrlResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error getting file URL: $e');
      return FileUrlResponse(sukses: false, url: '');
    }
  }

  /// Get file metadata by ID
  /// GET /api/upload/metadata/:id
  static Future<FileMetadataResponse> getFileMetadata(String fileId) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return FileMetadataResponse(sukses: false);
      }

      final uri = Uri.parse('$baseUrl/api/upload/metadata/$fileId');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      _logger.d('Get file metadata response: ${response.statusCode}');

      final responseData = jsonDecode(response.body);
      return FileMetadataResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error getting file metadata: $e');
      return FileMetadataResponse(sukses: false);
    }
  }

  /// Delete file by ID
  /// DELETE /api/upload/:id
  static Future<HapusFileResponse> deleteFile(String fileId) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return HapusFileResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/upload/$fileId');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      _logger.d('Delete file response: ${response.statusCode}');

      final responseData = jsonDecode(response.body);
      return HapusFileResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error deleting file: $e');
      return HapusFileResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Process image (resize/compress)
  /// POST /api/upload/image/:id/process
  static Future<ProcessImageResponse> processImage({
    required String fileId,
    int? lebar,
    int? tinggi,
    int? kualitas,
    String? format,
    String? fit,
    bool? pertahankanAspekRasio,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return ProcessImageResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/upload/image/$fileId/process');

      final body = <String, dynamic>{};
      if (lebar != null) body['lebar'] = lebar;
      if (tinggi != null) body['tinggi'] = tinggi;
      if (kualitas != null) body['kualitas'] = kualitas;
      if (format != null) body['format'] = format;
      if (fit != null) body['fit'] = fit;
      if (pertahankanAspekRasio != null) {
        body['pertahankanAspekRasio'] = pertahankanAspekRasio;
      }

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      _logger.d('Process image response: ${response.statusCode}');

      final responseData = jsonDecode(response.body);
      return ProcessImageResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error processing image: $e');
      return ProcessImageResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Process image with preset
  /// POST /api/upload/image/:id/preset/:preset
  static Future<ProcessImageResponse> processImageWithPreset({
    required String fileId,
    required ImagePreset preset,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return ProcessImageResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/upload/image/$fileId/preset/${preset.value}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      _logger.d('Process image preset response: ${response.statusCode}');

      final responseData = jsonDecode(response.body);
      return ProcessImageResponse.fromJson(responseData);
    } catch (e) {
      _logger.e('Error processing image with preset: $e');
      return ProcessImageResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Get download URL for file
  /// Returns the full URL to download the file
  static String getDownloadUrl(String fileId) {
    return '$baseUrl/api/upload/$fileId';
  }

  /// Build full URL for file access
  static String buildFileUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http')) {
      return relativeUrl;
    }
    return '$baseUrl$relativeUrl';
  }
}

/// Upload Response Model
class UploadResponse {
  final bool sukses;
  final String pesan;
  final UploadData? data;

  UploadResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? UploadData.fromJson(json['data']) : null,
    );
  }
}

/// Upload Data Model
class UploadData {
  final String id;
  final String namaFileAsli;
  final String namaFileSimpan;
  final String url;
  final String? urlPublik;
  final int ukuran;
  final String mimeType;
  final String ekstensi;
  final String tujuan;
  final String path;

  UploadData({
    required this.id,
    required this.namaFileAsli,
    required this.namaFileSimpan,
    required this.url,
    this.urlPublik,
    required this.ukuran,
    required this.mimeType,
    required this.ekstensi,
    required this.tujuan,
    required this.path,
  });

  factory UploadData.fromJson(Map<String, dynamic> json) {
    return UploadData(
      id: json['id'] ?? '',
      namaFileAsli: json['namaFileAsli'] ?? '',
      namaFileSimpan: json['namaFileSimpan'] ?? '',
      url: json['url'] ?? '',
      urlPublik: json['urlPublik'],
      ukuran: json['ukuran'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      ekstensi: json['ekstensi'] ?? '',
      tujuan: json['tujuan'] ?? '',
      path: json['path'] ?? '',
    );
  }
}
