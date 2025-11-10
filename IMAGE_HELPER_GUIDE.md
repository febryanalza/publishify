# Solusi Menampilkan Gambar dari Backend

## 📋 Deskripsi Masalah

Backend mengirimkan URL gambar dalam bentuk **path relatif** seperti:
```
/storage/images/photo.jpg
```

Sedangkan Flutter `Image.network()` membutuhkan **URL lengkap** seperti:
```
http://10.0.2.2:4000/storage/images/photo.jpg
```

## ✅ Solusi Implementasi

### 1. **ImageHelper Utility** (`lib/utils/image_helper.dart`)

Dibuat helper class untuk mengatasi masalah ini:

```dart
class ImageHelper {
  /// Konversi path relatif menjadi URL lengkap
  static String getFullImageUrl(String? urlPath) {
    if (urlPath == null || urlPath.isEmpty) {
      return '';
    }

    // Jika sudah URL lengkap, langsung return
    if (urlPath.startsWith('http://') || urlPath.startsWith('https://')) {
      return urlPath;
    }

    // Gabungkan dengan BASE_URL dari .env
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:4000';
    final cleanBaseUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = urlPath.startsWith('/') 
        ? urlPath 
        : '/$urlPath';

    return '$cleanBaseUrl$cleanPath';
  }
}
```

### 2. **File yang Diupdate**

Semua file yang menggunakan `Image.network()` telah diupdate:

#### ✅ `lib/widgets/cards/book_card.dart`
```dart
Image.network(
  ImageHelper.getFullImageUrl(book.imageUrl),
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return _buildPlaceholder();
  },
)
```

#### ✅ `lib/pages/profile/profile_page.dart`
- Avatar profil pengguna
- Cover naskah dalam portfolio

#### ✅ `lib/widgets/print_card.dart`
- Cover buku dalam kartu percetakan

#### ✅ `lib/widgets/percetakan_card.dart`
- Gambar percetakan

#### ✅ `lib/widgets/profile/portfolio_item.dart`
- Gambar portfolio item

## 🧪 Cara Menguji

### Test 1: URL Relatif dari Backend
```dart
// Input dari backend
String backendUrl = "/storage/images/sampul123.jpg";

// Output setelah ImageHelper
String fullUrl = ImageHelper.getFullImageUrl(backendUrl);
// Result: "http://10.0.2.2:4000/storage/images/sampul123.jpg"
```

### Test 2: URL Lengkap (External)
```dart
// Input URL lengkap
String externalUrl = "https://example.com/image.jpg";

// Output tetap sama
String fullUrl = ImageHelper.getFullImageUrl(externalUrl);
// Result: "https://example.com/image.jpg"
```

### Test 3: Null/Empty Handling
```dart
String? nullUrl = null;
String fullUrl = ImageHelper.getFullImageUrl(nullUrl);
// Result: ""
```

## 📝 Contoh Penggunaan

### Menampilkan Sampul Naskah
```dart
// Data dari backend
final naskah = NaskahData(
  id: '123',
  judul: 'Buku Saya',
  urlSampul: '/storage/sampul/buku-123.jpg', // Path relatif
  // ... field lain
);

// Tampilkan gambar
Image.network(
  ImageHelper.getFullImageUrl(naskah.urlSampul),
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.book); // Fallback jika error
  },
)
```

### Menampilkan Avatar Pengguna
```dart
// Data profil dari backend
final profile = ProfilPengguna(
  urlAvatar: '/storage/avatars/user-456.jpg', // Path relatif
  // ... field lain
);

// Tampilkan avatar
CircleAvatar(
  backgroundImage: NetworkImage(
    ImageHelper.getFullImageUrl(profile.urlAvatar),
  ),
  onBackgroundImageError: (error, stackTrace) {
    // Fallback ke icon default
  },
)
```

## 🔧 Konfigurasi Environment

File `.env` harus berisi BASE_URL:

```env
# Untuk Android Emulator
BASE_URL=http://10.0.2.2:4000

# Untuk iOS Simulator
BASE_URL=http://localhost:4000

# Untuk Device fisik (gunakan IP komputer)
BASE_URL=http://192.168.1.100:4000
```

## ⚠️ Error Handling

Semua implementasi sudah dilengkapi dengan error handling:

```dart
Image.network(
  ImageHelper.getFullImageUrl(urlSampul),
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    // Tampilkan placeholder jika gambar gagal load
    return Container(
      color: AppTheme.greyLight,
      child: Icon(Icons.book, color: AppTheme.greyMedium),
    );
  },
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    // Tampilkan loading indicator
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
)
```

## 📊 Manfaat Solusi Ini

1. ✅ **Flexible**: Mendukung URL relatif dan URL lengkap
2. ✅ **Centralized**: Satu tempat untuk mengatur logika URL
3. ✅ **Easy to Update**: Ubah BASE_URL di satu tempat (.env)
4. ✅ **Null Safe**: Menangani null/empty dengan baik
5. ✅ **Clean Code**: Tidak perlu menulis logika berulang

## 🚀 Testing Checklist

- [ ] Upload naskah dengan sampul
- [ ] Lihat sampul di halaman home
- [ ] Lihat sampul di halaman profile
- [ ] Lihat avatar pengguna
- [ ] Test dengan gambar tidak ada (error handling)
- [ ] Test dengan berbagai format path
- [ ] Test dengan URL external (https://)

## 💡 Tips Debugging

Jika gambar tidak muncul:

1. **Cek Console Log**: Lihat error message dari Image.network
2. **Cek URL**: Print hasil dari `ImageHelper.getFullImageUrl()`
3. **Cek Backend**: Pastikan file benar-benar ada di server
4. **Cek Network**: Pastikan emulator/device bisa akses backend
5. **Cek BASE_URL**: Pastikan BASE_URL di .env benar

```dart
// Debug URL
final fullUrl = ImageHelper.getFullImageUrl(naskah.urlSampul);
print('Full Image URL: $fullUrl');
```

## 📖 Referensi

- Flutter Image.network: https://api.flutter.dev/flutter/widgets/Image/Image.network.html
- NetworkImage: https://api.flutter.dev/flutter/painting/NetworkImage-class.html
- Error Handling: https://docs.flutter.dev/cookbook/images/network-image
