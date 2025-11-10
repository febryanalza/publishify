import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/utils/image_helper.dart';

/// Demo page untuk menguji ImageHelper dengan berbagai skenario
class ImageHelperDemoPage extends StatefulWidget {
  const ImageHelperDemoPage({super.key});

  @override
  State<ImageHelperDemoPage> createState() => _ImageHelperDemoPageState();
}

class _ImageHelperDemoPageState extends State<ImageHelperDemoPage> {
  // Test cases
  final List<Map<String, String>> testCases = [
    {
      'title': 'Path Relatif - Sampul Naskah',
      'input': '/storage/sampul/buku-123.jpg',
      'type': 'relative',
    },
    {
      'title': 'Path Relatif - Avatar',
      'input': '/storage/avatars/user-456.png',
      'type': 'relative',
    },
    {
      'title': 'URL Lengkap - External Image',
      'input': 'https://picsum.photos/300/400',
      'type': 'external',
    },
    {
      'title': 'URL Lengkap - Unsplash',
      'input':
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&h=400',
      'type': 'external',
    },
    {
      'title': 'Path Tanpa Leading Slash',
      'input': 'storage/percetakan/logo.png',
      'type': 'relative',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          'Image Helper Demo',
          style: TextStyle(color: AppTheme.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Info
          _buildInfoCard(),
          const SizedBox(height: 20),

          // Test Cases
          ...testCases.map((testCase) => _buildTestCard(testCase)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: AppTheme.primaryGreen.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tentang ImageHelper',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'ImageHelper mengkonversi path relatif dari backend menjadi URL lengkap.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Path relatif: /storage/images/photo.jpg\n'
              '• URL lengkap: http://10.0.2.2:4000/storage/images/photo.jpg',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(Map<String, String> testCase) {
    final input = testCase['input']!;
    final fullUrl = ImageHelper.getFullImageUrl(input);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  testCase['type'] == 'relative'
                      ? Icons.folder
                      : Icons.language,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    testCase['title']!,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Input
            _buildUrlDisplay('Input', input, AppTheme.errorRed),
            const SizedBox(height: 8),

            // Arrow
            const Center(
              child: Icon(
                Icons.arrow_downward,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),

            // Output
            _buildUrlDisplay('Output (Full URL)', fullUrl, AppTheme.primaryGreen),
            const SizedBox(height: 16),

            // Image Preview
            _buildImagePreview(fullUrl),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlDisplay(String label, String url, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.greyMedium,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: SelectableText(
            url,
            style: AppTheme.bodySmall.copyWith(
              fontFamily: 'monospace',
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.greyMedium,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.greyLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.greyDisabled),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading image...',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: AppTheme.errorRed,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gambar tidak dapat dimuat',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.errorRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          error.toString(),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.greyMedium,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
