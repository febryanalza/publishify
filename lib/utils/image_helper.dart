import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Helper untuk menangani URL gambar dari backend
class ImageHelper {
  /// Base URL backend dari environment
  static String get _baseUrl {
    final url = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:4000';
    // Remove trailing slash jika ada
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Mengkonversi relative path menjadi full URL
  /// 
  /// Contoh:
  /// - Input: `/uploads/sampul/2025-11-04_lukisan_a6011cc09612df7e.jpg`
  /// - Output: `http://10.0.2.2:4000/uploads/sampul/2025-11-04_lukisan_a6011cc09612df7e.jpg`
  /// 
  /// Jika input sudah full URL (dimulai dengan http/https), langsung return
  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }

    // Jika sudah full URL, return as is
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }

    // Tambahkan leading slash jika tidak ada
    final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    
    // Gabungkan base URL dengan path
    return '$_baseUrl$path';
  }

  /// Check apakah URL valid dan bisa digunakan
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    // Cek apakah URL atau path valid
    return url.isNotEmpty && 
           (url.startsWith('http://') || 
            url.startsWith('https://') || 
            url.startsWith('/uploads/'));
  }

  /// Get full URL untuk sampul buku
  static String? getSampulUrl(String? urlSampul) {
    if (!isValidImageUrl(urlSampul)) {
      return null;
    }
    return getFullImageUrl(urlSampul);
  }

  /// Get full URL untuk file naskah
  static String? getNaskahUrl(String? urlFile) {
    if (urlFile == null || urlFile.isEmpty) {
      return null;
    }
    return getFullImageUrl(urlFile);
  }

  /// Get full URL untuk avatar/profile picture
  static String? getAvatarUrl(String? urlAvatar) {
    if (!isValidImageUrl(urlAvatar)) {
      return null;
    }
    return getFullImageUrl(urlAvatar);
  }
}
