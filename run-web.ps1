# Script untuk menjalankan Flutter Web Development dengan port yang konsisten
# Usage: .\run-web.ps1 [-Mode debug|profile|release]

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("debug", "profile", "release")]
    [string]$Mode = "profile"
)

Write-Host "🚀 Starting Flutter Web Development Environment" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Check if Flutter is installed
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCommand) {
    Write-Host "❌ Flutter tidak ditemukan. Pastikan Flutter sudah terinstall." -ForegroundColor Red
    exit 1
}

# Set port untuk Flutter Web
$FlutterPort = 3001

Write-Host "📱 Starting Flutter Web on port $FlutterPort in $Mode mode" -ForegroundColor Cyan
Write-Host "🌐 URL: http://localhost:$FlutterPort" -ForegroundColor Yellow
Write-Host "🔗 Backend: http://localhost:4000" -ForegroundColor Yellow
Write-Host ""

# Mode-specific messages
switch ($Mode) {
    "debug" {
        Write-Host "⚠️  DEBUG MODE: DebugService errors akan muncul (bisa diabaikan)" -ForegroundColor Yellow
        Write-Host "💡 Tips: Error 'Cannot send Null' tidak mempengaruhi fungsi app" -ForegroundColor Gray
    }
    "profile" {
        Write-Host "⚡ PROFILE MODE: Optimized untuk testing dengan minimal debug noise" -ForegroundColor Green
        Write-Host "💡 Tips: Mode terbaik untuk development dan testing" -ForegroundColor Gray
    }
    "release" {
        Write-Host "🚀 RELEASE MODE: Production-like, tanpa debug errors" -ForegroundColor Green
        Write-Host "💡 Tips: Tidak ada hot reload di mode ini" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "💡 General Tips:" -ForegroundColor Blue
Write-Host "   - Pastikan backend berjalan di http://localhost:4000" -ForegroundColor Gray
Write-Host "   - Gunakan Ctrl+C untuk menghentikan" -ForegroundColor Gray
if ($Mode -eq "debug" -or $Mode -eq "profile") {
    Write-Host "   - Gunakan 'r' untuk hot reload" -ForegroundColor Gray
}
Write-Host ""

# Run Flutter web dengan mode yang ditentukan
flutter run -d chrome --$Mode --web-port $FlutterPort