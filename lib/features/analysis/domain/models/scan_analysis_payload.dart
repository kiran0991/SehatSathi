import '../../../scanner/domain/models/ocr_result.dart';
import '../../../scanner/domain/models/uploaded_image.dart';
import 'ingredient_analysis_result.dart';

class ScanAnalysisPayload {
  const ScanAnalysisPayload({
    required this.uploadedImage,
    required this.ocrResult,
    required this.analysisResult,
  });

  final UploadedImage uploadedImage;
  final OcrResult ocrResult;
  final IngredientAnalysisResult analysisResult;
}
