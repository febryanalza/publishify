import 'package:flutter/material.dart';
import 'package:publishify/utils/image_helper.dart';
import 'package:publishify/utils/theme.dart';

/// Widget untuk menampilkan network image dengan penanganan error dan loading
class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Get full URL dari relative path
    final fullUrl = ImageHelper.getFullImageUrl(imageUrl);

    if (fullUrl.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget = Image.network(
      fullUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return _buildLoadingWidget(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $error');
        debugPrint('Image URL: $fullUrl');
        return _buildErrorWidget();
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: AppTheme.backgroundLight,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryGreen,
              ),
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: AppTheme.backgroundLight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 40,
                color: AppTheme.greyMedium.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Gambar tidak tersedia',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
  }
}

/// Widget khusus untuk sampul buku
class SampulBukuImage extends StatelessWidget {
  final String? urlSampul;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SampulBukuImage({
    super.key,
    required this.urlSampul,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return NetworkImageWidget(
      imageUrl: urlSampul,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius,
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 50,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Sampul Buku',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget khusus untuk avatar/profile picture
class AvatarImage extends StatelessWidget {
  final String? urlAvatar;
  final double size;
  final String? fallbackText;

  const AvatarImage({
    super.key,
    required this.urlAvatar,
    this.size = 40,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final fullUrl = ImageHelper.getAvatarUrl(urlAvatar);

    if (fullUrl == null || fullUrl.isEmpty) {
      return _buildFallbackAvatar();
    }

    return ClipOval(
      child: Image.network(
        fullUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            width: size,
            height: size,
            color: AppTheme.backgroundLight,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: fallbackText != null && fallbackText!.isNotEmpty
            ? Text(
                fallbackText![0].toUpperCase(),
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.primaryGreen,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                size: size * 0.6,
                color: AppTheme.primaryGreen,
              ),
      ),
    );
  }
}
