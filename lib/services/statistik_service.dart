import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/services/auth_service.dart';

class StatistikService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  /// GET /api/naskah/statistik
  /// Mengambil statistik penulis
  static Future<StatistikResponse> ambilStatistikPenulis() async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        throw Exception('Token akses tidak ditemukan');
      }

      final url = Uri.parse('$baseUrl/api/naskah/statistik');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return StatistikResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['pesan'] ?? 'Gagal mengambil statistik');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}

// Models untuk response statistik
class StatistikResponse {
  final bool sukses;
  final String pesan;
  final StatistikData? data;

  StatistikResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory StatistikResponse.fromJson(Map<String, dynamic> json) {
    return StatistikResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? StatistikData.fromJson(json['data']) : null,
    );
  }
}

class StatistikData {
  final int totalNaskah;
  final int naskahDiterbitkan;
  final int naskahDalamReview;
  final int naskahDraft;
  final double ratingRataRata;
  final int totalDibaca;
  final List<StatistikBulanan> penjualanBulanan;
  final List<KomentarTerbaru> komentarTerbaru;
  final List<StatistikRating> distribusiRating;
  final List<StatistikGenre> naskahPerGenre;
  final List<StatistikStatus> naskahPerStatus;

  StatistikData({
    required this.totalNaskah,
    required this.naskahDiterbitkan,
    required this.naskahDalamReview,
    required this.naskahDraft,
    required this.ratingRataRata,
    required this.totalDibaca,
    required this.penjualanBulanan,
    required this.komentarTerbaru,
    required this.distribusiRating,
    required this.naskahPerGenre,
    required this.naskahPerStatus,
  });

  factory StatistikData.fromJson(Map<String, dynamic> json) {
    return StatistikData(
      totalNaskah: json['totalNaskah'] ?? 0,
      naskahDiterbitkan: json['naskahDiterbitkan'] ?? 0,
      naskahDalamReview: json['naskahDalamReview'] ?? 0,
      naskahDraft: json['naskahDraft'] ?? 0,
      ratingRataRata: (json['ratingRataRata'] ?? 0.0).toDouble(),
      totalDibaca: json['totalDibaca'] ?? 0,
      penjualanBulanan: (json['penjualanBulanan'] as List<dynamic>?)
          ?.map((e) => StatistikBulanan.fromJson(e))
          .toList() ?? [],
      komentarTerbaru: (json['komentarTerbaru'] as List<dynamic>?)
          ?.map((e) => KomentarTerbaru.fromJson(e))
          .toList() ?? [],
      distribusiRating: (json['distribusiRating'] as List<dynamic>?)
          ?.map((e) => StatistikRating.fromJson(e))
          .toList() ?? [],
      naskahPerGenre: (json['naskahPerGenre'] as List<dynamic>?)
          ?.map((e) => StatistikGenre.fromJson(e))
          .toList() ?? [],
      naskahPerStatus: (json['naskahPerStatus'] as List<dynamic>?)
          ?.map((e) => StatistikStatus.fromJson(e))
          .toList() ?? [],
    );
  }
}

class StatistikBulanan {
  final String bulan;
  final int tahun;
  final int jumlahDibaca;
  final double pendapatan;

  StatistikBulanan({
    required this.bulan,
    required this.tahun,
    required this.jumlahDibaca,
    required this.pendapatan,
  });

  factory StatistikBulanan.fromJson(Map<String, dynamic> json) {
    return StatistikBulanan(
      bulan: json['bulan'] ?? '',
      tahun: json['tahun'] ?? 0,
      jumlahDibaca: json['jumlahDibaca'] ?? 0,
      pendapatan: (json['pendapatan'] ?? 0.0).toDouble(),
    );
  }

  // Helper method untuk chart
  String get label => '$bulan $tahun';
  double get value => jumlahDibaca.toDouble();
}

class KomentarTerbaru {
  final String id;
  final String isiKomentar;
  final String namaPembaca;
  final String judulNaskah;
  final double rating;
  final String tanggal;

  KomentarTerbaru({
    required this.id,
    required this.isiKomentar,
    required this.namaPembaca,
    required this.judulNaskah,
    required this.rating,
    required this.tanggal,
  });

  factory KomentarTerbaru.fromJson(Map<String, dynamic> json) {
    return KomentarTerbaru(
      id: json['id'] ?? '',
      isiKomentar: json['isiKomentar'] ?? '',
      namaPembaca: json['namaPembaca'] ?? '',
      judulNaskah: json['judulNaskah'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      tanggal: json['tanggal'] ?? '',
    );
  }
}

class StatistikRating {
  final int star;
  final int jumlah;
  final double persentase;

  StatistikRating({
    required this.star,
    required this.jumlah,
    required this.persentase,
  });

  factory StatistikRating.fromJson(Map<String, dynamic> json) {
    return StatistikRating(
      star: json['star'] ?? 0,
      jumlah: json['jumlah'] ?? 0,
      persentase: (json['persentase'] ?? 0.0).toDouble(),
    );
  }
}

class StatistikGenre {
  final String namaGenre;
  final int jumlahNaskah;
  final double persentase;

  StatistikGenre({
    required this.namaGenre,
    required this.jumlahNaskah,
    required this.persentase,
  });

  factory StatistikGenre.fromJson(Map<String, dynamic> json) {
    return StatistikGenre(
      namaGenre: json['namaGenre'] ?? '',
      jumlahNaskah: json['jumlahNaskah'] ?? 0,
      persentase: (json['persentase'] ?? 0.0).toDouble(),
    );
  }
}

class StatistikStatus {
  final String status;
  final int jumlah;
  final double persentase;

  StatistikStatus({
    required this.status,
    required this.jumlah,
    required this.persentase,
  });

  factory StatistikStatus.fromJson(Map<String, dynamic> json) {
    return StatistikStatus(
      status: json['status'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      persentase: (json['persentase'] ?? 0.0).toDouble(),
    );
  }
}