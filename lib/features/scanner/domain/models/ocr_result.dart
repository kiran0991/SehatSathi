import 'ocr_ingredient.dart';

class OcrResult {
  const OcrResult({
    required this.rawText,
    required this.ingredients,
    this.ingredientsText,
    this.confidence,
  });

  final String rawText;
  final List<OcrIngredient> ingredients;
  final String? ingredientsText;
  final double? confidence;

  bool get hasIngredients => ingredients.isNotEmpty;
}
