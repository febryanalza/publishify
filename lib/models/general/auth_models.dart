// Model untuk Request Register
class RegisterRequest {
  final String email;
  final String kataSandi;
  final String konfirmasiKataSandi;
  final String namaDepan;
  final String namaBelakang;
  final String telepon;
  final String jenisPeran;

  RegisterRequest({
    required this.email,
    required this.kataSandi,
    required this.konfirmasiKataSandi,
    required this.namaDepan,
    required this.namaBelakang,
    required this.telepon,
    required this.jenisPeran,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'kataSandi': kataSandi,
      'konfirmasiKataSandi': konfirmasiKataSandi,
      'namaDepan': namaDepan,
      'namaBelakang': namaBelakang,
      'telepon': telepon,
      'jenisPeran': jenisPeran,
    };
  }
}

// Model untuk Response Register
class RegisterResponse {
  final bool sukses;
  final String pesan;
  final RegisterData? data;

  RegisterResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }
}

class RegisterData {
  final String id;
  final String email;
  final String tokenVerifikasi;
  // Optional: jika backend mengirim token langsung saat registrasi
  final String? accessToken;
  final String? refreshToken;
  final UserData? pengguna;

  RegisterData({
    required this.id,
    required this.email,
    required this.tokenVerifikasi,
    this.accessToken,
    this.refreshToken,
    this.pengguna,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      tokenVerifikasi: json['tokenVerifikasi'] ?? '',
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      pengguna: json['pengguna'] != null ? UserData.fromJson(json['pengguna']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'tokenVerifikasi': tokenVerifikasi,
      if (accessToken != null) 'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (pengguna != null) 'pengguna': pengguna!.toJson(),
    };
  }
}

// ===== LOGIN MODELS =====

// Model untuk Request Login
class LoginRequest {
  final String email;
  final String kataSandi;

  LoginRequest({
    required this.email,
    required this.kataSandi,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'kataSandi': kataSandi,
      'platform': 'mobile',
    };
  }
}

// Model untuk Response Login
class LoginResponse {
  final bool sukses;
  final String pesan;
  final LoginData? data;

  LoginResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final String accessToken;
  final String refreshToken;
  final UserData pengguna;

  LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.pengguna,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      pengguna: UserData.fromJson(json['pengguna'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'pengguna': pengguna.toJson(),
    };
  }
}

class UserData {
  final String id;
  final String email;
  final List<String> peran; // Untuk kompatibilitas, tetap ada untuk response backend sederhana
  final bool terverifikasi;
  final ProfilPengguna? profilPengguna;
  final List<PeranPengguna>? peranPengguna; // Tambahan untuk struktur lengkap

  UserData({
    required this.id,
    required this.email,
    required this.peran,
    required this.terverifikasi,
    this.profilPengguna,
    this.peranPengguna,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      peran: (json['peran'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      terverifikasi: json['terverifikasi'] ?? false,
      profilPengguna: json['profilPengguna'] != null
          ? ProfilPengguna.fromJson(json['profilPengguna'])
          : null,
      peranPengguna: (json['peranPengguna'] as List<dynamic>?)
          ?.map((e) => PeranPengguna.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'peran': peran,
      'terverifikasi': terverifikasi,
      'profilPengguna': profilPengguna?.toJson(),
      'peranPengguna': peranPengguna?.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper method untuk mendapatkan peran aktif
  List<String> getActiveRoles() {
    if (peranPengguna != null) {
      return peranPengguna!
          .where((p) => p.aktif)
          .map((p) => p.jenisPeran)
          .toList();
    }
    return peran;
  }

  /// Helper method untuk cek apakah user memiliki peran tertentu
  bool hasRole(String role) {
    return getActiveRoles().contains(role);
  }

  /// Helper method untuk mendapatkan peran utama (peran pertama yang aktif)
  String? getPrimaryRole() {
    final activeRoles = getActiveRoles();
    return activeRoles.isNotEmpty ? activeRoles.first : null;
  }
}

class ProfilPengguna {
  final String id;
  final String idPengguna;
  final String namaDepan;
  final String namaBelakang;
  final String namaTampilan;
  final String? bio;
  final String? urlAvatar;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final String? kodePos;
  final String dibuatPada;
  final String diperbaruiPada;

  ProfilPengguna({
    required this.id,
    required this.idPengguna,
    required this.namaDepan,
    required this.namaBelakang,
    required this.namaTampilan,
    this.bio,
    this.urlAvatar,
    this.tanggalLahir,
    this.jenisKelamin,
    this.alamat,
    this.kota,
    this.provinsi,
    this.kodePos,
    required this.dibuatPada,
    required this.diperbaruiPada,
  });

  factory ProfilPengguna.fromJson(Map<String, dynamic> json) {
    return ProfilPengguna(
      id: json['id'] ?? '',
      idPengguna: json['idPengguna'] ?? '',
      namaDepan: json['namaDepan'] ?? '',
      namaBelakang: json['namaBelakang'] ?? '',
      namaTampilan: json['namaTampilan'] ?? '',
      bio: json['bio'],
      urlAvatar: json['urlAvatar'],
      tanggalLahir: json['tanggalLahir'],
      jenisKelamin: json['jenisKelamin'],
      alamat: json['alamat'],
      kota: json['kota'],
      provinsi: json['provinsi'],
      kodePos: json['kodePos'],
      dibuatPada: json['dibuatPada'] ?? '',
      diperbaruiPada: json['diperbaruiPada'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPengguna': idPengguna,
      'namaDepan': namaDepan,
      'namaBelakang': namaBelakang,
      'namaTampilan': namaTampilan,
      'bio': bio,
      'urlAvatar': urlAvatar,
      'tanggalLahir': tanggalLahir,
      'jenisKelamin': jenisKelamin,
      'alamat': alamat,
      'kota': kota,
      'provinsi': provinsi,
      'kodePos': kodePos,
      'dibuatPada': dibuatPada,
      'diperbaruiPada': diperbaruiPada,
    };
  }
}

// ===== PERAN PENGGUNA MODEL =====

/// Model untuk PeranPengguna sesuai dengan backend
class PeranPengguna {
  final String id;
  final String idPengguna;
  final String jenisPeran; // 'penulis', 'editor', 'percetakan', 'admin'
  final bool aktif;
  final String ditugaskanPada;
  final String? ditugaskanOleh;

  PeranPengguna({
    required this.id,
    required this.idPengguna,
    required this.jenisPeran,
    required this.aktif,
    required this.ditugaskanPada,
    this.ditugaskanOleh,
  });

  factory PeranPengguna.fromJson(Map<String, dynamic> json) {
    return PeranPengguna(
      id: json['id'] ?? '',
      idPengguna: json['idPengguna'] ?? '',
      jenisPeran: json['jenisPeran'] ?? '',
      aktif: json['aktif'] ?? false,
      ditugaskanPada: json['ditugaskanPada'] ?? '',
      ditugaskanOleh: json['ditugaskanOleh'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPengguna': idPengguna,
      'jenisPeran': jenisPeran,
      'aktif': aktif,
      'ditugaskanPada': ditugaskanPada,
      'ditugaskanOleh': ditugaskanOleh,
    };
  }
}

// ===== JENIS PERAN ENUM =====

/// Enum untuk JenisPeran sesuai dengan backend
enum JenisPeran {
  penulis,
  editor,
  percetakan,
  admin,
}

/// Extension untuk JenisPeran
extension JenisPeranExtension on JenisPeran {
  String get value {
    switch (this) {
      case JenisPeran.penulis:
        return 'penulis';
      case JenisPeran.editor:
        return 'editor';
      case JenisPeran.percetakan:
        return 'percetakan';
      case JenisPeran.admin:
        return 'admin';
    }
  }

  String get displayName {
    switch (this) {
      case JenisPeran.penulis:
        return 'Penulis';
      case JenisPeran.editor:
        return 'Editor';
      case JenisPeran.percetakan:
        return 'Percetakan';
      case JenisPeran.admin:
        return 'Admin';
    }
  }

  static JenisPeran fromString(String value) {
    switch (value.toLowerCase()) {
      case 'penulis':
        return JenisPeran.penulis;
      case 'editor':
        return JenisPeran.editor;
      case 'percetakan':
        return JenisPeran.percetakan;
      case 'admin':
        return JenisPeran.admin;
      default:
        return JenisPeran.penulis; // default
    }
  }
}
