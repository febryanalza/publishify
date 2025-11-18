#!/bin/bash

# Script untuk menjalankan Flutter Web Development dengan port yang konsisten

echo "🚀 Starting Flutter Web Development Environment"
echo "================================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter tidak ditemukan. Pastikan Flutter sudah terinstall."
    exit 1
fi

# Set port untuk Flutter Web
FLUTTER_PORT=3001

echo "📱 Starting Flutter Web on port $FLUTTER_PORT"
echo "🌐 URL: http://localhost:$FLUTTER_PORT"
echo "🔗 Backend: http://localhost:4000"
echo ""
echo "💡 Tips:"
echo "   - Pastikan backend berjalan di http://localhost:4000"
echo "   - Gunakan Ctrl+C untuk menghentikan"
echo "   - Gunakan 'r' untuk hot reload"
echo ""

# Run Flutter web dengan port yang ditentukan
flutter run -d chrome --web-port $FLUTTER_PORT --debug