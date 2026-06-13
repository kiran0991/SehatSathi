import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/supabase/supabase_bootstrap.dart';
import '../../domain/models/ocr_ingredient.dart';
import '../../domain/models/ocr_result.dart';
import '../../domain/models/uploaded_image.dart';

abstract class OcrService {
  Future<OcrResult> extractIngredients(UploadedImage image);
}

class SupabaseOcrService implements OcrService {
  SupabaseOcrService(this._client);

  final supabase.SupabaseClient _client;

  static const functionName = 'ocr-extract';
  static const bucketName = 'scan-images';

  @override
  Future<OcrResult> extractIngredients(UploadedImage image) async {
    late final dynamic response;
    try {
      response = await _client.functions.invoke(
        functionName,
        body: {
          'bucket': bucketName,
          'imagePath': image.path,
          'imageUrl': image.publicUrl,
        },
      );
    } catch (error) {
      final message = error.toString();
      if (message.contains('Failed to fetch')) {
        throw StateError(
          'OCR function could not be reached. Deploy the Supabase Edge Function `ocr-extract` and ensure it returns CORS headers for browser requests.',
        );
      }
      throw StateError(message.replaceFirst('Bad state: ', ''));
    }

    final payload = _asMap(response.data);
    final rawText = (payload['raw_text'] ?? payload['text'] ?? '')
        .toString()
        .trim();
    final ingredientsText =
        (payload['ingredients_text'] ?? payload['structured_ingredients_text'])
            ?.toString()
            .trim();

    final structuredIngredients = parseIngredients(
      payload['ingredients'] as List<dynamic>?,
      ingredientsText: ingredientsText,
      rawText: rawText,
    );

    return OcrResult(
      rawText: rawText,
      ingredientsText: ingredientsText,
      ingredients: structuredIngredients,
      confidence: _toDouble(payload['confidence']),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    throw StateError('OCR response was not in the expected format.');
  }

  static List<OcrIngredient> parseIngredients(
    List<dynamic>? ingredients, {
    required String? ingredientsText,
    required String rawText,
  }) {
    if (ingredients != null && ingredients.isNotEmpty) {
      return ingredients
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .map((item) => OcrIngredient(name: item, originalText: item))
          .toList();
    }

    final source = _resolveIngredientsSource(
      ingredientsText: ingredientsText,
      rawText: rawText,
    );

    return _splitIngredients(source);
  }

  static String _resolveIngredientsSource({
    required String? ingredientsText,
    required String rawText,
  }) {
    if (ingredientsText != null && ingredientsText.isNotEmpty) {
      return ingredientsText;
    }

    final normalized = rawText.replaceAll('\n', ' ');
    final match = RegExp(
      r'ingredients?\s*[:\-]\s*(.+?)(?:allergen|nutrition|contains|storage|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(normalized);

    if (match != null) {
      return match.group(1)?.trim() ?? rawText;
    }

    return rawText;
  }

  static List<OcrIngredient> _splitIngredients(String source) {
    final cleaned = source
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[^:]*:\s*', caseSensitive: false), '')
        .trim();

    if (cleaned.isEmpty) {
      return const [];
    }

    return cleaned
        .split(RegExp(r',|\u2022|;'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map(
          (part) => OcrIngredient(
            name: _normalizeIngredientName(part),
            originalText: part,
          ),
        )
        .toList();
  }

  static String _normalizeIngredientName(String value) {
    return value
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }
}

class UnconfiguredOcrService implements OcrService {
  @override
  Future<OcrResult> extractIngredients(UploadedImage image) {
    throw StateError(
      'Supabase is not configured. Pass `SUPABASE_URL` and `SUPABASE_ANON_KEY` when running the app.',
    );
  }

  bool get isConfigured => SupabaseBootstrapConfig.isConfigured;
}
