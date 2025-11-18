# Flutter Web Development Configuration

## Menjalankan Flutter Web

Untuk menjalankan Flutter aplikasi di web browser (Chrome), gunakan perintah berikut:

```bash
# Menjalankan di port default (biasanya port acak)
flutter run -d chrome

# Menjalankan di port spesifik (3001)
flutter run -d chrome --web-port 3001

# Menjalankan dengan hot reload dan debug
flutter run -d chrome --web-port 3001 --debug

# Menjalankan dalam mode release (production-like)
flutter run -d chrome --web-port 3001 --release
```

## Port Configuration

- **Backend**: http://localhost:4000
- **Flutter Web**: http://localhost:3001 (direkomendasikan)
- **Alternative ports**: 3000, 5000, 5001, 8080

## CORS Setup

Backend sudah dikonfigurasi untuk menerima request dari multiple ports untuk development:
- localhost:3000-3001
- localhost:5000-5001  
- localhost:8080

## Troubleshooting

Jika masih mendapat CORS error:

1. **Restart backend** setelah perubahan konfigurasi CORS
2. **Clear browser cache** atau gunakan incognito mode
3. **Check console** untuk error message yang lebih detail
4. **Verify port** yang digunakan Flutter web

## Environment Variables

Pastikan file `.env` menggunakan localhost untuk web:

```
BASE_URL=http://localhost:4000
```

## Development Workflow

1. Start backend: `bun run start:dev` (di folder backend)
2. Start Flutter web: `flutter run -d chrome --web-port 3001` (di folder publishify)
3. Open browser ke http://localhost:3001