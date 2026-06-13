import '../../domain/models/ocr_result.dart';
import '../../domain/models/uploaded_image.dart';
import '../services/ocr_service.dart';

class OcrRepository {
  const OcrRepository(this._service);

  final OcrService _service;

  Future<OcrResult> extractIngredients(UploadedImage image) {
    return _service.extractIngredients(image);
  }
}
