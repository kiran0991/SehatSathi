import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_sathi/features/scanner/data/repositories/ocr_repository.dart';
import 'package:sehat_sathi/features/scanner/data/services/ocr_service.dart';
import 'package:sehat_sathi/features/scanner/domain/models/ocr_ingredient.dart';
import 'package:sehat_sathi/features/scanner/domain/models/ocr_result.dart';
import 'package:sehat_sathi/features/scanner/domain/models/uploaded_image.dart';

void main() {
  group('OcrRepository', () {
    test('returns OCR result from service', () async {
      final repository = OcrRepository(FakeOcrService());

      final result = await repository.extractIngredients(
        const UploadedImage(
          path: 'user-1/image.jpg',
          publicUrl: 'https://example.com/image.jpg',
        ),
      );

      expect(result.ingredients.first.name, 'Sugar');
      expect(result.confidence, 0.94);
    });
  });
}

class FakeOcrService implements OcrService {
  @override
  Future<OcrResult> extractIngredients(UploadedImage image) async {
    return const OcrResult(
      rawText: 'Ingredients: Sugar, Salt',
      ingredientsText: 'Sugar, Salt',
      confidence: 0.94,
      ingredients: [
        OcrIngredient(name: 'Sugar', originalText: 'Sugar'),
        OcrIngredient(name: 'Salt', originalText: 'Salt'),
      ],
    );
  }
}
