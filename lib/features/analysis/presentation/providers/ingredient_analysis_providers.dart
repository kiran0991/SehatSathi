import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/domain/models/health_profile.dart';
import '../../../scanner/domain/models/ocr_result.dart';
import '../../data/repositories/ingredient_analysis_repository.dart';
import '../../data/services/ingredient_analysis_service.dart';
import '../../domain/models/ingredient_analysis_result.dart';

final ingredientAnalysisServiceProvider = Provider<IngredientAnalysisService>((
  ref,
) {
  return DeterministicIngredientAnalysisService();
});

final ingredientAnalysisRepositoryProvider =
    Provider<IngredientAnalysisRepository>((ref) {
      return IngredientAnalysisRepository(
        ref.watch(ingredientAnalysisServiceProvider),
      );
    });

final ingredientAnalysisProvider =
    Provider.family<IngredientAnalysisResult, IngredientAnalysisInput>((
      ref,
      input,
    ) {
      return ref
          .watch(ingredientAnalysisRepositoryProvider)
          .analyze(
            ocrResult: input.ocrResult,
            healthProfile: input.healthProfile,
          );
    });

class IngredientAnalysisInput {
  const IngredientAnalysisInput({
    required this.ocrResult,
    required this.healthProfile,
  });

  final OcrResult ocrResult;
  final HealthProfile healthProfile;
}
