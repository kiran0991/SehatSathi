import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_sathi/features/analysis/data/services/ingredient_analysis_service.dart';
import 'package:sehat_sathi/features/profile/domain/models/health_profile.dart';
import 'package:sehat_sathi/features/scanner/domain/models/ocr_ingredient.dart';
import 'package:sehat_sathi/features/scanner/domain/models/ocr_result.dart';

void main() {
  group('DeterministicIngredientAnalysisService', () {
    final service = DeterministicIngredientAnalysisService();

    test(
      'returns watch-outs and diabetes warning for sugary ingredient list',
      () {
        final result = service.analyze(
          ocrResult: const OcrResult(
            rawText: 'Ingredients: Sugar, Refined Wheat Flour, Palm Oil, Salt',
            ingredients: [
              OcrIngredient(name: 'Sugar'),
              OcrIngredient(name: 'Refined Wheat Flour'),
              OcrIngredient(name: 'Palm Oil'),
              OcrIngredient(name: 'Salt'),
            ],
          ),
          healthProfile: const HealthProfile(
            conditions: [HealthProfile.diabetes],
            allergies: [HealthProfile.none],
            goal: HealthProfile.healthyEating,
          ),
        );

        expect(result.healthScore, lessThan(50));
        expect(
          result.watchOutIngredients.map((item) => item.name),
          contains('Sugar'),
        );
        expect(
          result.warnings.map((item) => item.title),
          contains('Added sugar watch-out'),
        );
        expect(result.summary, contains('This product looks'));
      },
    );

    test('returns good signals for whole-grain style ingredient list', () {
      final result = service.analyze(
        ocrResult: const OcrResult(
          rawText: 'Ingredients: Whole Wheat, Oats, Cocoa',
          ingredients: [
            OcrIngredient(name: 'Whole Wheat'),
            OcrIngredient(name: 'Oats'),
            OcrIngredient(name: 'Cocoa'),
          ],
        ),
        healthProfile: HealthProfile.initial(),
      );

      expect(result.healthScore, greaterThan(60));
      expect(result.goodIngredients.map((item) => item.name), contains('Oats'));
      expect(result.watchOutIngredients, isEmpty);
    });

    test('returns allergy warning for gluten-sensitive profile', () {
      final result = service.analyze(
        ocrResult: const OcrResult(
          rawText: 'Ingredients: Wheat Flour, Sugar',
          ingredients: [
            OcrIngredient(name: 'Wheat Flour'),
            OcrIngredient(name: 'Sugar'),
          ],
        ),
        healthProfile: const HealthProfile(
          conditions: [HealthProfile.none],
          allergies: [HealthProfile.gluten],
          goal: HealthProfile.none,
        ),
      );

      expect(
        result.warnings.map((item) => item.title),
        contains('Gluten alert'),
      );
    });
  });
}
