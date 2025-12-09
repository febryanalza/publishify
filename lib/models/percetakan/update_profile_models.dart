// Model untuk Request Update Profile
class UpdateProfileRequest {
  final String? namaDepan;
  final String? namaBelakang;
  final String? namaTampilan;
  final String? bio;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final String? kodePos;
  final String? telepon;

  UpdateProfileRequest({
    this.namaDepan,
    this.namaBelakang,
    this.namaTampilan,
    this.bio,
    this.tanggalLahir,
    this.jenisKelamin,
    this.alamat,
    this.kota,
    this.provinsi,
    this.kodePos,
    this.telepon,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (namaDepan != null) data['namaDepan'] = namaDepan;
    if (namaBelakang != null) data['namaBelakang'] = namaBelakang;
    if (namaTampilan != null) data['namaTampilan'] = namaTampilan;
    if (bio != null) data['bio'] = bio;
    if (tanggalLahir != null) data['tanggalLahir'] = tanggalLahir;
    if (jenisKelamin != null) data['jenisKelamin'] = jenisKelamin;
    if (alamat != null) data['alamat'] = alamat;
    if (kota != null) data['kota'] = kota;
    if (provinsi != null) data['provinsi'] = provinsi;
    if (kodePos != null) data['kodePos'] = kodePos;
    if (telepon != null) data['telepon'] = telepon;
    
    return data;
  }
}

// Model untuk Response Update Profile
class UpdateProfileResponse {
  final bool sukses;
  final String pesan;
  final UpdatedUserData? data;
  final List<ValidationError>? errors;

  UpdateProfileResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.errors,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null
          ? UpdatedUserData.fromJson(json['data'])
          : null,
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => ValidationError.fromJson(e))
              .toList()
          : null,
    );
  }
}

// Model untuk Validation Error
class ValidationError {
  final String field;
  final String message;

  ValidationError({
    required this.field,
    required this.message,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
    };
  }
}

class UpdatedUserData {
  final String id;
  final String email;
  final String? telepon;
  final UpdatedProfilPengguna? profilPengguna;

  UpdatedUserData({
    required this.id,
    required this.email,
    this.telepon,
    this.profilPengguna,
  });

  factory UpdatedUserData.fromJson(Map<String, dynamic> json) {
    return UpdatedUserData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      telepon: json['telepon'],
      profilPengguna: json['profilPengguna'] != null
          ? UpdatedProfilPengguna.fromJson(json['profilPengguna'])
          : null,
    );
  }
}

class UpdatedProfilPengguna {
  final String id;
  final String? namaDepan;
  final String? namaBelakang;
  final String? namaTampilan;
  final String? bio;
  final String? urlAvatar;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final String? kodePos;
  final String? diperbaruiPada;

  UpdatedProfilPengguna({
    required this.id,
    this.namaDepan,
    this.namaBelakang,
    this.namaTampilan,
    this.bio,
    this.urlAvatar,
    this.tanggalLahir,
    this.jenisKelamin,
    this.alamat,
    this.kota,
    this.provinsi,
    this.kodePos,
    this.diperbaruiPada,
  });

  factory UpdatedProfilPengguna.fromJson(Map<String, dynamic> json) {
    return UpdatedProfilPengguna(
      id: json['id'] ?? '',
      namaDepan: json['namaDepan'],
      namaBelakang: json['namaBelakang'],
      namaTampilan: json['namaTampilan'],
      bio: json['bio'],
      urlAvatar: json['urlAvatar'],
      tanggalLahir: json['tanggalLahir'],
      jenisKelamin: json['jenisKelamin'],
      alamat: json['alamat'],
      kota: json['kota'],
      provinsi: json['provinsi'],
      kodePos: json['kodePos'],
      diperbaruiPada: json['diperbaruiPada'],
    );
  }
}
