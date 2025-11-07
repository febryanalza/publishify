import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/services/auth_service.dart';
import 'package:mime/mime.dart';

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
  final String namaFile;
  final String namaAsli;
  final String mimeType;
  final int ukuran;
  final String url;
  final String path;

  UploadData({
    required this.id,
    required this.namaFile,
    required this.namaAsli,
    required this.mimeType,
    required this.ukuran,
    required this.url,
    required this.path,
  });

  factory UploadData.fromJson(Map<String, dynamic> json) {
    return UploadData(
      id: json['id'] ?? '',
      namaFile: json['namaFile'] ?? '',
      namaAsli: json['namaAsli'] ?? '',
      mimeType: json['mimeType'] ?? '',
      ukuran: json['ukuran'] ?? 0,
      url: json['url'] ?? '',
      path: json['path'] ?? '',
    );
  }
}
