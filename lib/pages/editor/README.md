# 📝 Editor Dashboard - Publishify

Dashboard khusus untuk role **Editor** dalam sistem Publishify. Dashboard ini menyediakan interface lengkap untuk mengelola review naskah, memberikan feedback, dan melakukan tugas-tugas editorial.

## 📋 Fitur Utama

### 🎯 Quick Actions
- **Review Baru**: Menampilkan jumlah review yang baru ditugaskan
- **Deadline Dekat**: Review dengan batas waktu dalam 1-2 hari
- **Beri Feedback**: Review yang memerlukan feedback tambahan
- **Review Selesai**: Review yang sudah diselesaikan hari ini

### 📊 Statistik Editor
- **Review Aktif**: Jumlah review yang sedang dikerjakan
- **Selesai Hari Ini**: Target pencapaian harian
- **Review Tertunda**: Review yang belum dimulai
- **Progress Bar**: Visualisasi pencapaian target harian

### 📚 Review Management
- **Review Terkini**: Daftar review assignment terbaru
- **Priority Indicator**: Visual indicator prioritas (Sangat Tinggi, Tinggi, Sedang, Rendah)
- **Status Tracking**: Ditugaskan, Sedang Review, Selesai, Ditolak
- **Deadline Warning**: Peringatan visual untuk deadline yang mendekat

### 🔧 Menu Editor
- **Review Naskah**: Kelola semua review yang ditugaskan
- **Beri Feedback**: Interface untuk memberikan feedback detail
- **Naskah Masuk**: Naskah baru yang perlu direview
- **Statistik Review**: Analytics performa review editor

## 📁 Struktur File

```
lib/
├── pages/editor/
│   └── editor_dashboard_page.dart          # Main dashboard page
├── models/editor/
│   └── editor_models.dart                  # Data models untuk editor
├── services/
│   └── editor_service.dart                 # Service layer dengan dummy data
└── widgets/editor/
    └── editor_widgets.dart                 # Custom widgets untuk editor
```

## 🎨 Design System

### Warna & Theme
- **Primary Green**: `#0F766E` - Header, buttons, accents
- **Status Colors**:
  - Ditugaskan: `Colors.blue`
  - Sedang Review: `Colors.orange` 
  - Selesai: `Colors.green`
  - Ditolak: `Colors.red`
- **Priority Colors**:
  - Sangat Tinggi (1): `Colors.red`
  - Tinggi (2): `Colors.orange`
  - Sedang (3): `Colors.blue`
  - Rendah (4-5): `AppTheme.greyMedium`

### Typography
- **Header**: 24px, Bold, White (pada header hijau)
- **Card Title**: 16px, SemiBold, Black
- **Body Text**: 14px, Normal, Grey
- **Small Text**: 12px, Normal, Grey

## 🔄 Data Management

### Dummy Data Structure
Service menggunakan data dummy yang mudah diganti dengan API calls:

```dart
// Editor Statistics
EditorStats(
  totalReviewDitugaskan: 15,
  reviewSelesaiHariIni: 3,
  reviewDalamProses: 7,
  reviewTertunda: 5,
  // ... 
)

// Review Assignments
ReviewAssignment(
  id: 'rev_001',
  judulNaskah: 'Petualangan di Nusantara',
  penulis: 'Ahmad Subhan',
  status: 'sedang_review',
  prioritas: 1, // 1=Sangat Tinggi, 5=Rendah
  // ...
)
```

### Backend Integration
Semua service method sudah disiapkan untuk integrasi backend:

```dart
// TODO: Ganti dengan API call
static Future<EditorStats> getEditorStats() async {
  // API endpoint: GET /api/editor/statistics
}

static Future<List<ReviewAssignment>> getReviewAssignments() async {
  // API endpoint: GET /api/editor/reviews  
}
```

## 📱 Responsiveness

Dashboard dirancang responsive untuk berbagai ukuran layar:
- **Mobile First**: Optimized untuk mobile devices
- **Tablet Support**: Layout menyesuaikan untuk tablet
- **Flexible Grid**: Row/Column layout yang fleksibel

## 🚀 Navigation & Routing

### Route Configuration
Dashboard editor terhubung dengan sistem role-based navigation:

```dart
// Route: /dashboard/editor
case '/dashboard/editor':
  return MaterialPageRoute(
    builder: (_) => EditorDashboardPage(),
  );
```

### Menu Navigation
Setiap menu item memiliki route yang sudah disiapkan:
- `/editor/reviews` - Review Naskah
- `/editor/feedback` - Beri Feedback  
- `/editor/naskah-masuk` - Naskah Masuk
- `/editor/statistics` - Statistik Review

## 🎯 Future Enhancements

### Phase 1: Basic Features
- [x] Dashboard layout dan UI
- [x] Dummy data dan service layer
- [x] Statistics cards dan progress tracking
- [x] Review assignment cards
- [x] Quick actions menu

### Phase 2: API Integration
- [ ] Connect ke backend API endpoints
- [ ] Real-time notifications
- [ ] Socket.io untuk update live
- [ ] Error handling dan loading states

### Phase 3: Advanced Features  
- [ ] Advanced filtering dan search
- [ ] Bulk review operations
- [ ] Review templates dan shortcuts
- [ ] Analytics dan reporting
- [ ] Export review data

## 💡 Usage Examples

### Accessing Editor Dashboard

```dart
// Navigate to editor dashboard
Navigator.pushNamed(context, '/dashboard/editor');

// Atau melalui role navigation controller
await RoleNavigationController.navigateAfterLogin(
  context, 
  userData.role // role: 'editor'
);
```

### Custom Widget Usage

```dart
// Menggunakan ReviewAssignmentCard
ReviewAssignmentCard(
  review: reviewAssignment,
  onTap: () => navigateToReviewDetail(review.id),
  onActionTap: () => startReview(review.id),
  actionLabel: 'Mulai Review',
  actionIcon: Icons.play_arrow,
)

// Menggunakan EditorStatsCard
EditorStatsCard(
  title: 'Review Aktif',
  value: 7,
  subtitle: 'Sedang dikerjakan',
  icon: Icons.assignment,
  color: Colors.orange,
  onTap: () => navigateToActiveReviews(),
)
```

## 🔧 Customization

### Mengubah Data Dummy
Edit file `lib/services/editor_service.dart`:

```dart
static Future<EditorStats> getEditorStats() async {
  return EditorStats(
    totalReviewDitugaskan: 20, // Ubah angka sesuai kebutuhan
    reviewSelesaiHariIni: 5,
    // ...
  );
}
```

### Menambah Quick Action
Edit method `getQuickActions()` di EditorService:

```dart
{
  'icon': 'new_icon',
  'label': 'New Action',
  'count': 10,
  'action': 'new_action',
  'color': 'purple',
},
```

### Custom Color Scheme
Edit method helper di dashboard page:

```dart
Color _getActionColor(String colorName) {
  switch (colorName) {
    case 'purple': return Colors.purple;
    // tambahkan warna baru
  }
}
```

## 📞 Support & Integration

Dashboard ini siap untuk integrasi dengan:
- **Backend API**: NestJS dengan endpoints `/api/editor/*`
- **Database**: PostgreSQL dengan tabel `review_naskah`  
- **Real-time**: Socket.io untuk notifikasi live
- **Authentication**: JWT token system
- **Role Management**: Role-based access control

Dashboard Editor Publishify memberikan experience yang optimal untuk editor dalam mengelola workflow review naskah dengan interface yang intuitif dan data management yang terstruktur.