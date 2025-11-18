# Script untuk menjalankan Flutter Web dalam Release Mode (tanpa debug errors)
# Usage: .\run-web-release.ps1

Write-Host "🚀 Starting Flutter Web in RELEASE MODE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Check if Flutter is installed
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCommand) {
    Write-Host "❌ Flutter tidak ditemukan. Pastikan Flutter sudah terinstall." -ForegroundColor Red
    exit 1
}

# Set port untuk Flutter Web
$FlutterPort = 3001

Write-Host "📱 Starting Flutter Web on port $FlutterPort in RELEASE mode" -ForegroundColor Cyan
Write-Host "🌐 URL: http://localhost:$FlutterPort" -ForegroundColor Yellow
Write-Host "🔗 Backend: http://localhost:4000" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ RELEASE MODE Benefits:" -ForegroundColor Green
Write-Host "   - Tidak ada DebugService errors" -ForegroundColor Gray
Write-Host "   - Performance optimal" -ForegroundColor Gray
Write-Host "   - Production-like behavior" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  RELEASE MODE Limitations:" -ForegroundColor Yellow
Write-Host "   - Tidak ada hot reload" -ForegroundColor Gray
Write-Host "   - Build time lebih lama" -ForegroundColor Gray
Write-Host "   - Debugging terbatas" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Blue
Write-Host "   - Pastikan backend berjalan di http://localhost:4000" -ForegroundColor Gray
Write-Host "   - Gunakan Ctrl+C untuk menghentikan" -ForegroundColor Gray
Write-Host "   - Restart script untuk melihat perubahan code" -ForegroundColor Gray
Write-Host ""

Write-Host "🏗️  Building Flutter Web Release..." -ForegroundColor Cyan

# Run Flutter web dalam release mode
flutter run -d chrome --release --web-port $FlutterPort