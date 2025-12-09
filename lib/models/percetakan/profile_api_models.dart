class ProfileApiResponse {
  final bool sukses;
  final String pesan;
  final ProfileUserData? data;

  ProfileApiResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory ProfileApiResponse.fromJson(Map<String, dynamic> json) {
    return ProfileApiResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? ProfileUserData.fromJson(json['data']) : null,
    );
  }
}

class ProfileUserData {
  final String id;
  final String email;
  final String? telepon;
  final bool aktif;
  final bool terverifikasi;
  final String? emailDiverifikasiPada;
  final String? loginTerakhir;
  final String dibuatPada;
  final String diperbaruiPada;
  final ProfilPengguna? profilPengguna;
  final List<PeranPengguna> peranPengguna;
  final ProfilPenulis? profilPenulis;

  ProfileUserData({
    required this.id,
    required this.email,
    this.telepon,
    required this.aktif,
    required this.terverifikasi,
    this.emailDiverifikasiPada,
    this.loginTerakhir,
    required this.dibuatPada,
    required this.diperbaruiPada,
    this.profilPengguna,
    required this.peranPengguna,
    this.profilPenulis,
  });

  factory ProfileUserData.fromJson(Map<String, dynamic> json) {
    return ProfileUserData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      telepon: json['telepon'],
      aktif: json['aktif'] ?? false,
      terverifikasi: json['terverifikasi'] ?? false,
      emailDiverifikasiPada: json['emailDiverifikasiPada'],
      loginTerakhir: json['loginTerakhir'],
      dibuatPada: json['dibuatPada'] ?? '',
      diperbaruiPada: json['diperbaruiPada'] ?? '',
      profilPengguna: json['profilPengguna'] != null
          ? ProfilPengguna.fromJson(json['profilPengguna'])
          : null,
      peranPengguna: (json['peranPengguna'] as List<dynamic>?)
              ?.map((e) => PeranPengguna.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      profilPenulis: json['profilPenulis'] != null
          ? ProfilPenulis.fromJson(json['profilPenulis'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'telepon': telepon,
      'aktif': aktif,
      'terverifikasi': terverifikasi,
      'emailDiverifikasiPada': emailDiverifikasiPada,
      'loginTerakhir': loginTerakhir,
      'dibuatPada': dibuatPada,
      'diperbaruiPada': diperbaruiPada,
      'profilPengguna': profilPengguna?.toJson(),
      'peranPengguna': peranPengguna.map((e) => e.toJson()).toList(),
      'profilPenulis': profilPenulis?.toJson(),
    };
  }
}

class ProfilPengguna {
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

  ProfilPengguna({
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
  });

  factory ProfilPengguna.fromJson(Map<String, dynamic> json) {
    return ProfilPengguna(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }
}

class PeranPengguna {
  final String id;
  final String jenisPeran;
  final bool aktif;
  final String? ditugaskanPada;

  PeranPengguna({
    required this.id,
    required this.jenisPeran,
    required this.aktif,
    this.ditugaskanPada,
  });

  factory PeranPengguna.fromJson(Map<String, dynamic> json) {
    return PeranPengguna(
      id: json['id'] ?? '',
      jenisPeran: json['jenisPeran'] ?? '',
      aktif: json['aktif'] ?? false,
      ditugaskanPada: json['ditugaskanPada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jenisPeran': jenisPeran,
      'aktif': aktif,
      'ditugaskanPada': ditugaskanPada,
    };
  }
}

class ProfilPenulis {
  final String id;
  final String? namaPena;
  final String? biografi;
  final List<String>? spesialisasi;
  final int? totalBuku;
  final int? totalDibaca;
  final String? ratingRataRata;
  final String? namaRekeningBank;
  final String? namaBank;
  final String? nomorRekeningBank;
  final String? npwp;

  ProfilPenulis({
    required this.id,
    this.namaPena,
    this.biografi,
    this.spesialisasi,
    this.totalBuku,
    this.totalDibaca,
    this.ratingRataRata,
    this.namaRekeningBank,
    this.namaBank,
    this.nomorRekeningBank,
    this.npwp,
  });

  factory ProfilPenulis.fromJson(Map<String, dynamic> json) {
    return ProfilPenulis(
      id: json['id'] ?? '',
      namaPena: json['namaPena'],
      biografi: json['biografi'],
      spesialisasi: (json['spesialisasi'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      totalBuku: json['totalBuku'],
      totalDibaca: json['totalDibaca'],
      ratingRataRata: json['ratingRataRata'],
      namaRekeningBank: json['namaRekeningBank'],
      namaBank: json['namaBank'],
      nomorRekeningBank: json['nomorRekeningBank'],
      npwp: json['npwp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaPena': namaPena,
      'biografi': biografi,
      'spesialisasi': spesialisasi,
      'totalBuku': totalBuku,
      'totalDibaca': totalDibaca,
      'ratingRataRata': ratingRataRata,
      'namaRekeningBank': namaRekeningBank,
      'namaBank': namaBank,
      'nomorRekeningBank': nomorRekeningBank,
      'npwp': npwp,
    };
  }
}
