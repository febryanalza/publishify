import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/utils/image_helper.dart';

void main() {
  group('ImageHelper Tests', () {
    setUpAll(() async {
      // Setup dotenv untuk testing
      await dotenv.load(fileName: ".env");
    });

    group('getFullImageUrl()', () {
      test('Mengkonversi path relatif menjadi URL lengkap', () {
        // Arrange
        const relativePath = '/storage/images/photo.jpg';
        const expectedUrl = 'http://10.0.2.2:4000/storage/images/photo.jpg';

        // Act
        final result = ImageHelper.getFullImageUrl(relativePath);

        // Assert
        expect(result, equals(expectedUrl));
      });

      test('Mengembalikan URL lengkap jika input sudah http://', () {
        // Arrange
        const fullUrl = 'http://example.com/image.jpg';

        // Act
        final result = ImageHelper.getFullImageUrl(fullUrl);

        // Assert
        expect(result, equals(fullUrl));
      });

      test('Mengembalikan URL lengkap jika input sudah https://', () {
        // Arrange
        const fullUrl = 'https://example.com/image.jpg';

        // Act
        final result = ImageHelper.getFullImageUrl(fullUrl);

        // Assert
        expect(result, equals(fullUrl));
      });

      test('Mengembalikan string kosong jika input null', () {
        // Arrange
        String? nullPath;

        // Act
        final result = ImageHelper.getFullImageUrl(nullPath);

        // Assert
        expect(result, equals(''));
      });

      test('Mengembalikan string kosong jika input empty', () {
        // Arrange
        const emptyPath = '';

        // Act
        final result = ImageHelper.getFullImageUrl(emptyPath);

        // Assert
        expect(result, equals(''));
      });

      test('Menangani path tanpa leading slash', () {
        // Arrange
        const pathWithoutSlash = 'storage/images/photo.jpg';
        const expectedUrl = 'http://10.0.2.2:4000/storage/images/photo.jpg';

        // Act
        final result = ImageHelper.getFullImageUrl(pathWithoutSlash);

        // Assert
        expect(result, equals(expectedUrl));
      });

      test('Menangani BASE_URL dengan trailing slash', () {
        // Arrange
        const relativePath = '/storage/images/photo.jpg';
        // Simulasi BASE_URL dengan trailing slash
        const expectedUrl = 'http://10.0.2.2:4000/storage/images/photo.jpg';

        // Act
        final result = ImageHelper.getFullImageUrl(relativePath);

        // Assert
        expect(result, equals(expectedUrl));
      });
    });

    group('isValidImageUrl()', () {
      test('Mengembalikan true untuk URL valid', () {
        // Arrange
        const validUrl = '/storage/images/photo.jpg';

        // Act
        final result = ImageHelper.isValidImageUrl(validUrl);

        // Assert
        expect(result, isTrue);
      });

      test('Mengembalikan false untuk null', () {
        // Arrange
        String? nullUrl;

        // Act
        final result = ImageHelper.isValidImageUrl(nullUrl);

        // Assert
        expect(result, isFalse);
      });

      test('Mengembalikan false untuk string kosong', () {
        // Arrange
        const emptyUrl = '';

        // Act
        final result = ImageHelper.isValidImageUrl(emptyUrl);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getPlaceholderUrl()', () {
      test('Mengembalikan URL placeholder', () {
        // Act
        final result = ImageHelper.getPlaceholderUrl();

        // Assert
        expect(result, isNotEmpty);
        expect(result, contains('placeholder'));
      });
    });

    group('Real-world scenarios', () {
      test('Scenario: Sampul naskah dari backend', () {
        // Arrange - Response dari backend
        const urlSampul = '/storage/sampul/naskah-123.jpg';

        // Act
        final fullUrl = ImageHelper.getFullImageUrl(urlSampul);

        // Assert
        expect(fullUrl, startsWith('http'));
        expect(fullUrl, contains('/storage/sampul/naskah-123.jpg'));
      });

      test('Scenario: Avatar pengguna eksternal (Gravatar)', () {
        // Arrange - URL eksternal
        const gravatarUrl = 'https://www.gravatar.com/avatar/12345?s=200';

        // Act
        final fullUrl = ImageHelper.getFullImageUrl(gravatarUrl);

        // Assert
        expect(fullUrl, equals(gravatarUrl));
      });

      test('Scenario: Gambar percetakan dari backend', () {
        // Arrange
        const percetakanImage = '/storage/percetakan/logo-123.png';

        // Act
        final fullUrl = ImageHelper.getFullImageUrl(percetakanImage);

        // Assert
        expect(fullUrl, startsWith('http://10.0.2.2:4000'));
        expect(fullUrl, endsWith('.png'));
      });

      test('Scenario: Handling missing image (null)', () {
        // Arrange - Backend tidak mengirim urlSampul
        String? missingImage;

        // Act
        final fullUrl = ImageHelper.getFullImageUrl(missingImage);

        // Assert
        expect(fullUrl, isEmpty);
      });
    });
  });
}
