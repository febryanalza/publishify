import 'package:flutter/material.dart';
import 'package:publishify/utils/image_helper.dart';
import 'package:publishify/widgets/network_image_widget.dart';
import 'package:publishify/utils/theme.dart';

/// Test page untuk memverifikasi Image Helper dan Network Image Widget
/// Jalankan page ini untuk memastikan gambar dari backend dapat ditampilkan
class ImageTestPage extends StatelessWidget {
  const ImageTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh URL dari backend
    const relativePath = '/uploads/sampul/2025-11-04_lukisan_a6011cc09612df7e.jpg';
    final fullUrl = ImageHelper.getFullImageUrl(relativePath);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image URL Test'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.yellow.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.yellow),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'URL Testing',
                    style: AppTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Relative Path dari Backend:',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    relativePath,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Full URL setelah konversi:',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullUrl,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryGreen,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test 1: NetworkImageWidget Generic
            Text(
              '1. NetworkImageWidget (Generic)',
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.greyDisabled),
                borderRadius: BorderRadius.circular(12),
              ),
              child: NetworkImageWidget(
                imageUrl: relativePath,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 24),

            // Test 2: SampulBukuImage
            Text(
              '2. SampulBukuImage (Khusus Buku)',
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 150,
                  child: SampulBukuImage(
                    urlSampul: relativePath,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  height: 150,
                  child: SampulBukuImage(
                    urlSampul: null, // Test null
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Test 3: AvatarImage
            Text(
              '3. AvatarImage (Profile Picture)',
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                AvatarImage(
                  urlAvatar: '/uploads/avatar/user_123.jpg',
                  size: 80,
                  fallbackText: 'John Doe',
                ),
                const SizedBox(width: 16),
                AvatarImage(
                  urlAvatar: null, // Test null
                  size: 80,
                  fallbackText: 'Jane Smith',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Test 4: Invalid URL
            Text(
              '4. Test Invalid URL (Error Handling)',
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.greyDisabled),
                borderRadius: BorderRadius.circular(12),
              ),
              child: NetworkImageWidget(
                imageUrl: '/uploads/sampul/tidak_ada.jpg',
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📝 Instruksi Testing:',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstruction(
                    '1. Pastikan backend running di http://10.0.2.2:4000',
                  ),
                  _buildInstruction(
                    '2. Upload gambar sampul via API atau Swagger',
                  ),
                  _buildInstruction(
                    '3. Copy relative path dari response API',
                  ),
                  _buildInstruction(
                    '4. Replace relativePath variable di code',
                  ),
                  _buildInstruction(
                    '5. Hot reload dan cek apakah gambar muncul',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '✅ Jika gambar muncul = SUCCESS!\n'
                    '❌ Jika error atau tidak muncul = Check backend URL',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
