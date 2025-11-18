# Halaman Pengumpulan Review Editor

## 📋 Overview

Halaman ini dirancang khusus untuk editor dalam mengelola buku-buku yang masuk untuk direview. Sistem ini menyediakan interface yang user-friendly untuk mengelola workflow review dengan berbagai status dan prioritas.

## ✨ Fitur Utama

### 1. **Filter Dropdown**
- **Semua Buku**: Menampilkan semua buku yang masuk
- **Belum Ditugaskan**: Buku yang belum ditugaskan ke editor manapun
- **Ditugaskan**: Buku yang sudah ditugaskan ke editor tertentu
- **Dalam Review**: Buku yang sedang dalam proses review
- **Selesai**: Buku yang sudah selesai direview

### 2. **Aksi pada Setiap Buku**
- **Terima Buku**: Editor dapat menerima buku untuk direview
- **Tugaskan Editor Lain**: Menugaskan buku ke editor lain dengan alasan yang jelas
- **Lihat Detail**: Melihat informasi lengkap dan memberikan review

### 3. **Sistem Prioritas**
- **Tinggi** (Merah): Urgent, perlu ditangani segera
- **Sedang** (Kuning): Normal, sesuai urutan
- **Rendah** (Hijau): Tidak urgent, bisa dikerjakan terakhir

### 4. **Status Badge Visual**
- Color-coded berdasarkan status review
- Informasi deadline dengan warning untuk yang mendekati batas waktu
- Metadata lengkap: penulis, genre, jumlah halaman, kata

## 📁 Struktur File

### Models (`lib/models/editor/review_collection_models.dart`)
```dart
// Model utama
- BukuMasukReview: Informasi buku yang masuk untuk review
- DetailBukuReview: Detail lengkap untuk halaman review
- RiwayatReview: History review dari editor lain
- InputReview: Data input untuk submit review
- EditorOption: Pilihan editor untuk reassignment

// Helper
- FilterReviewOption: Options untuk filter dropdown
- ReviewCollectionResponse<T>: Wrapper response API
```

### Services (`lib/services/editor/review_collection_service.dart`)
```dart
// Main methods
+ getBukuMasukReview() - Ambil daftar buku dengan filter
+ getDetailBuku() - Ambil detail buku untuk review
+ terimaBuku() - Accept buku untuk direview
+ tugaskanEditorLain() - Reassign ke editor lain
+ submitReview() - Submit review dengan rating dan feedback
+ getAvailableEditors() - Daftar editor tersedia untuk reassignment

// Dummy data helpers (mudah diganti saat integrasi backend)
- _getDummyBooks(): Sample data buku
- _getDummyRiwayatReview(): Sample riwayat review
- _getDummyKeywords(): Sample keywords berdasarkan genre
- _getFilterCounts(): Hitung jumlah per filter
```

### Pages
```
lib/pages/editor/review/
├── review_collection_page.dart    # Halaman utama list buku
└── review_detail_page.dart        # Halaman detail dan form review
```

## 🎨 UI Components

### ReviewCollectionPage
- **Header**: Judul, subtitle, dan icon tema
- **Info Card**: Penjelasan singkat fungsi halaman
- **Filter Dropdown**: Dengan icon dan counter untuk setiap status
- **Stats Row**: Jumlah hasil dan info sorting
- **Book Cards**: Card untuk setiap buku dengan:
  - Status badge dan priority badge
  - Cover placeholder
  - Metadata lengkap (penulis, genre, halaman, tanggal, deadline)
  - Sinopsis preview
  - Action buttons (Terima, Tugaskan, Detail)

### ReviewDetailPage
- **Book Info Card**: Detail lengkap buku dengan cover
- **Metadata Card**: Informasi tambahan (waktu baca, kompleksitas, estimasi review)
- **Riwayat Review**: History review dari editor lain
- **Review Form**: 
  - Pilihan rekomendasi (Setujui, Revisi, Tolak)
  - Rating bintang 1-5
  - Text area untuk catatan review
  - Text area untuk feedback detail

### Dialog Components
- **TugaskanEditorDialog**: Modal untuk memilih editor dan alasan penugasan
- **Loading States**: Loading indicator saat network request
- **Error States**: Error handling dengan retry button
- **Empty States**: UI ketika tidak ada data

## 🔄 Data Flow

### 1. Load Initial Data
```
ReviewCollectionPage.initState()
→ ReviewCollectionService.getBukuMasukReview()
→ Update UI dengan data dan filter counts
```

### 2. Filter Change
```
User selects filter
→ _onFilterChanged()
→ Call service dengan filter baru
→ Update list dan UI
```

### 3. Accept Book
```
User tap "Terima Buku"
→ _onTerimaBuku()
→ Show loading dialog
→ ReviewCollectionService.terimaBuku()
→ Show success/error message
→ Reload data
```

### 4. Reassign Book
```
User tap "Tugaskan Editor Lain"
→ Show TugaskanEditorDialog
→ Load available editors
→ User select editor + input reason
→ ReviewCollectionService.tugaskanEditorLain()
→ Show success/error message
→ Reload data
```

### 5. Review Submission
```
ReviewDetailPage
→ User input rekomendasi, rating, catatan
→ _submitReview()
→ ReviewCollectionService.submitReview()
→ Show success message
→ Navigate back to collection page
```

## 🌐 Backend Integration

### Current State: Dummy Data
Semua service methods menggunakan dummy data dengan delay simulation untuk mengimitasi network request.

### Ready for Backend Integration
Setiap service method memiliki comment `// TODO: Replace dengan API call` dengan contoh endpoint yang diperlukan:

```dart
// Contoh integrasi backend
static Future<ReviewCollectionResponse<List<BukuMasukReview>>> getBukuMasukReview({
  String filter = 'semua',
  int page = 1,
  int limit = 20,
}) async {
  try {
    // Replace dummy data dengan actual API call
    final response = await http.get('/api/editor/review-collection?filter=$filter&page=$page&limit=$limit');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReviewCollectionResponse<List<BukuMasukReview>>(
        sukses: data['sukses'],
        pesan: data['pesan'],
        data: (data['data'] as List).map((item) => BukuMasukReview.fromJson(item)).toList(),
        metadata: data['metadata'],
      );
    }
    // Error handling...
  } catch (e) {
    // Error handling...
  }
}
```

### Expected API Endpoints
```
GET  /api/editor/review-collection?filter={status}&page={n}&limit={n}
GET  /api/editor/review-collection/{id}
POST /api/editor/review-collection/{id}/accept
POST /api/editor/review-collection/{id}/reassign
POST /api/editor/review-collection/submit
GET  /api/editor/available
```

## 🎯 Color Scheme (AppTheme)

### Status Colors
- **Belum Ditugaskan**: `AppTheme.googleYellow` (Kuning)
- **Ditugaskan**: `AppTheme.googleBlue` (Biru)  
- **Dalam Review**: `AppTheme.primaryGreen` (Hijau primer)
- **Selesai**: `AppTheme.googleGreen` (Hijau)

### Priority Colors
- **Tinggi**: `AppTheme.errorRed` (Merah)
- **Sedang**: `AppTheme.googleYellow` (Kuning)
- **Rendah**: `AppTheme.googleGreen` (Hijau)

### Interactive Elements
- **Primary Button**: `AppTheme.primaryGreen`
- **Secondary Button**: `AppTheme.googleBlue`
- **Outline Button**: Border sesuai context
- **Cards**: `AppTheme.white` dengan shadow

## 📱 Navigation Integration

### Routes (app_routes.dart)
```dart
case '/editor/reviews':
  return MaterialPageRoute(
    builder: (_) => ReviewCollectionPage(),
    settings: settings,
  );
```

### Dashboard Integration
Editor dashboard memiliki:
- **Quick Actions**: Link langsung ke review collection
- **Menu Items**: "Kelola Review Masuk" → `/editor/reviews`
- **Stats Cards**: Tap untuk filter review collection

### Navigation Flow
```
EditorDashboardPage
→ Tap "Review Baru" atau "Kelola Review"
→ Navigator.pushNamed('/editor/reviews')
→ ReviewCollectionPage
→ Tap "Lihat Detail" pada buku
→ Navigator.push(ReviewDetailPage)
→ Submit review
→ Navigator.pop() kembali ke collection
```

## 🧪 Testing Checklist

### UI Testing
- [ ] Filter dropdown menampilkan count yang benar
- [ ] Status badge menampilkan warna yang tepat
- [ ] Priority badge sesuai dengan prioritas
- [ ] Loading state muncul saat request
- [ ] Error state dengan retry button berfungsi
- [ ] Empty state muncul ketika tidak ada data
- [ ] Pull to refresh berfungsi

### Functionality Testing  
- [ ] Filter mengubah list dengan benar
- [ ] Accept buku menampilkan loading dan sukses message
- [ ] Reassign editor dialog berfungsi
- [ ] Editor selection dan alasan input required
- [ ] Detail page memuat data dengan benar
- [ ] Review form validation berfungsi
- [ ] Submit review berhasil dan navigate back
- [ ] Deadline warning muncul untuk buku urgent

### Navigation Testing
- [ ] Dashboard → Review Collection navigation
- [ ] Collection → Detail → Collection navigation
- [ ] Back button berfungsi di semua halaman
- [ ] App routes konfigurasi benar

### Data Testing
- [ ] Dummy data realistic dan varied
- [ ] JSON serialization berfungsi
- [ ] Filter counts akurat
- [ ] Sort by priority dan date berfungsi

## 🚀 Future Enhancements

### Fitur Tambahan
1. **Search**: Pencarian buku berdasarkan judul/penulis
2. **Sort Options**: Multiple sorting (tanggal, prioritas, status)
3. **Bulk Actions**: Select multiple books untuk batch operations
4. **Notifications**: Push notification untuk deadline dan assignment
5. **Analytics**: Dashboard statistik review performance
6. **File Preview**: Preview PDF/document dalam app

### Performance Optimizations
1. **Pagination**: Infinite scroll atau pagination
2. **Caching**: Local storage untuk offline access
3. **Image Optimization**: Lazy loading untuk book covers
4. **Search Debouncing**: Optimize search input

### User Experience
1. **Swipe Actions**: Swipe to accept/reassign
2. **Quick Filters**: Chips untuk quick filter selection
3. **Bookmarks**: Bookmark important books
4. **Notes**: Personal notes pada setiap book
5. **Templates**: Review template untuk consistency

---

## 📞 Support

Untuk questions atau issues terkait halaman review collection:

1. **File Structure**: Pastikan semua files di path yang benar
2. **Dependencies**: Verify import statements
3. **Theme**: Gunakan AppTheme constants untuk consistency  
4. **Navigation**: Test route configuration
5. **Data Models**: Validate JSON structure untuk backend integration

**Files Created:**
- `lib/models/editor/review_collection_models.dart`
- `lib/services/editor/review_collection_service.dart`
- `lib/pages/editor/review/review_collection_page.dart`
- `lib/pages/editor/review/review_detail_page.dart`

**Files Modified:**
- `lib/routes/app_routes.dart` (added route)
- `lib/pages/editor/home/editor_dashboard_page.dart` (navigation integration)
- `lib/models/editor/editor_models.dart` (export addition)
- `lib/services/editor/editor_services.dart` (export addition)