import '../../../profile/domain/models/health_profile.dart';
import '../../../scanner/domain/models/ocr_result.dart';
import '../../domain/models/ingredient_analysis_result.dart';
import '../services/ingredient_analysis_service.dart';

class IngredientAnalysisRepository {
  const IngredientAnalysisRepository(this._service);

  final IngredientAnalysisService _service;

  IngredientAnalysisResult analyze({
    required OcrResult ocrResult,
    required HealthProfile healthProfile,
  }) {
    return _service.analyze(ocrResult: ocrResult, healthProfile: healthProfile);
  }
}
