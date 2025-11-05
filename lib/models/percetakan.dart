class Percetakan {
  final String id;
  final String nama;
  final String imageUrl;
  final String alamat;
  final String? telepon;
  final double? rating;
  final int? jumlahReview;
  final String? deskripsi;

  Percetakan({
    required this.id,
    required this.nama,
    required this.imageUrl,
    required this.alamat,
    this.telepon,
    this.rating,
    this.jumlahReview,
    this.deskripsi,
  });

  // Dummy data for testing
  static List<Percetakan> getDummyData() {
    return [
      Percetakan(
        id: '1',
        nama: 'Percetakan 1',
        imageUrl: 'https://picsum.photos/seed/print1/400/300',
        alamat: 'Jl. Percetakan Negara No. 1, Jakarta Pusat',
        telepon: '021-12345678',
        rating: 4.5,
        jumlahReview: 120,
        deskripsi: 'Percetakan profesional dengan kualitas terbaik',
      ),
      Percetakan(
        id: '2',
        nama: 'Percetakan 2',
        imageUrl: 'https://picsum.photos/seed/print2/400/300',
        alamat: 'Jl. Industri No. 25, Jakarta Selatan',
        telepon: '021-87654321',
        rating: 4.3,
        jumlahReview: 85,
        deskripsi: 'Spesialis cetak buku dan majalah',
      ),
      Percetakan(
        id: '3',
        nama: 'Percetakan 3',
        imageUrl: 'https://picsum.photos/seed/print3/400/300',
        alamat: 'Jl. Raya Bogor KM 20, Depok',
        telepon: '021-98765432',
        rating: 4.7,
        jumlahReview: 150,
        deskripsi: 'Harga terjangkau, hasil memuaskan',
      ),
      Percetakan(
        id: '4',
        nama: 'Percetakan 4',
        imageUrl: 'https://picsum.photos/seed/print4/400/300',
        alamat: 'Jl. Gatot Subroto No. 45, Jakarta Barat',
        telepon: '021-55667788',
        rating: 4.2,
        jumlahReview: 95,
        deskripsi: 'Percetakan modern dengan teknologi terkini',
      ),
      Percetakan(
        id: '5',
        nama: 'Percetakan 5',
        imageUrl: 'https://picsum.photos/seed/print5/400/300',
        alamat: 'Jl. Sudirman No. 88, Tangerang',
        telepon: '021-44556677',
        rating: 4.6,
        jumlahReview: 110,
        deskripsi: 'Percetakan berpengalaman sejak 1990',
      ),
      Percetakan(
        id: '6',
        nama: 'Percetakan 6',
        imageUrl: 'https://picsum.photos/seed/print6/400/300',
        alamat: 'Jl. Ahmad Yani No. 12, Bekasi',
        telepon: '021-33445566',
        rating: 4.4,
        jumlahReview: 78,
        deskripsi: 'Fast printing dengan hasil berkualitas',
      ),
      Percetakan(
        id: '7',
        nama: 'Percetakan 7',
        imageUrl: 'https://picsum.photos/seed/print7/400/300',
        alamat: 'Jl. Thamrin No. 99, Jakarta Pusat',
        telepon: '021-22334455',
        rating: 4.8,
        jumlahReview: 200,
        deskripsi: 'Premium printing services',
      ),
      Percetakan(
        id: '8',
        nama: 'Percetakan 8',
        imageUrl: 'https://picsum.photos/seed/print8/400/300',
        alamat: 'Jl. Mangga Dua No. 77, Jakarta Utara',
        telepon: '021-11223344',
        rating: 4.1,
        jumlahReview: 65,
        deskripsi: 'Cetak cepat dengan harga bersaing',
      ),
    ];
  }
}
