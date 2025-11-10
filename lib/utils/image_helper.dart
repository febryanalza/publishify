import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Helper class untuk mengelola URL gambar dari backend
class ImageHelper {
  /// Mendapatkan URL lengkap untuk gambar
  /// 
  /// Jika urlPath sudah berupa URL lengkap (http/https), langsung return
  /// Jika urlPath adalah path relatif (/storage/...), gabungkan dengan BASE_URL
  /// 
  /// Contoh:
  /// - Input: "/storage/images/photo.jpg"
  /// - Output: "http://10.0.2.2:4000/storage/images/photo.jpg"
  static String getFullImageUrl(String? urlPath) {
    if (urlPath == null || urlPath.isEmpty) {
      return '';
    }

    // Jika sudah URL lengkap (http/https), langsung return
    if (urlPath.startsWith('http://') || urlPath.startsWith('https://')) {
      return urlPath;
    }

    // Ambil BASE_URL dari .env
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:4000';
    
    // Pastikan baseUrl tidak diakhiri dengan /
    final cleanBaseUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    
    // Pastikan path diawali dengan /
    final cleanPath = urlPath.startsWith('/') 
        ? urlPath 
        : '/$urlPath';

    return '$cleanBaseUrl$cleanPath';
  }

  /// Cek apakah URL gambar valid
  static bool isValidImageUrl(String? urlPath) {
    if (urlPath == null || urlPath.isEmpty) {
      return false;
    }
    return true;
  }

  /// Mendapatkan placeholder image URL
  static String getPlaceholderUrl() {
    return 'https://via.placeholder.com/300x400?text=No+Image';
  }
}
