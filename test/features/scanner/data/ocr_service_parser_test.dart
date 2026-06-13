import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_sathi/features/scanner/domain/models/ocr_ingredient.dart';
import 'package:sehat_sathi/features/scanner/data/services/ocr_service.dart';

void main() {
  group('SupabaseOcrService parsing', () {
    test('extracts ingredients from OCR text fallback', () {
      final service = OcrParserTestHarness();

      final result = service.parseForTest(
        rawText:
            'Ingredients: Refined Wheat Flour (Maida), Sugar, Edible Oil, Salt. Allergen Information: Contains Wheat.',
        ingredientsText: null,
        ingredients: null,
      );

      expect(result.map((item) => item.name).toList(), [
        'Refined Wheat Flour',
        'Sugar',
        'Edible Oil',
        'Salt.',
      ]);
    });

    test('uses structured list when provided', () {
      final service = OcrParserTestHarness();

      final result = service.parseForTest(
        rawText: 'ignored',
        ingredientsText: null,
        ingredients: ['Sugar', 'Palm Oil'],
      );

      expect(result.map((item) => item.name).toList(), ['Sugar', 'Palm Oil']);
    });
  });
}

class OcrParserTestHarness {
  List<OcrIngredient> parseForTest({
    required String rawText,
    required String? ingredientsText,
    required List<dynamic>? ingredients,
  }) {
    return SupabaseOcrService.parseIngredients(
      ingredients,
      ingredientsText: ingredientsText,
      rawText: rawText,
    );
  }
}
