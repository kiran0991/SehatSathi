import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sehat_sathi/features/scanner/data/repositories/ocr_repository.dart';
import 'package:sehat_sathi/features/scanner/data/services/ocr_service.dart';
import 'package:sehat_sathi/features/scanner/domain/models/ocr_ingredient.dart';
import 'package:sehat_sathi/features/scanner/domain/models/ocr_result.dart';
import 'package:sehat_sathi/features/scanner/domain/models/uploaded_image.dart';
import 'package:sehat_sathi/features/scanner/presentation/providers/ocr_providers.dart';

void main() {
  group('OcrController', () {
    test('extractIngredients stores OCR result', () async {
      final container = ProviderContainer(
        overrides: [
          ocrRepositoryProvider.overrideWithValue(
            OcrRepository(FakeOcrService()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(ocrControllerProvider.notifier)
          .extractIngredients(
            const UploadedImage(
              path: 'user-1/image.jpg',
              publicUrl: 'https://example.com/image.jpg',
            ),
          );

      expect(result.ingredients.length, 2);
      expect(
        container.read(ocrControllerProvider).requireValue?.ingredientsText,
        'Wheat Flour, Sugar',
      );
    });
  });
}

class FakeOcrService implements OcrService {
  @override
  Future<OcrResult> extractIngredients(UploadedImage image) async {
    return const OcrResult(
      rawText: 'Ingredients: Wheat Flour, Sugar',
      ingredientsText: 'Wheat Flour, Sugar',
      confidence: 0.89,
      ingredients: [
        OcrIngredient(name: 'Wheat Flour', originalText: 'Wheat Flour'),
        OcrIngredient(name: 'Sugar', originalText: 'Sugar'),
      ],
    );
  }
}
