import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_bootstrap.dart';
import '../../data/repositories/ocr_repository.dart';
import '../../data/services/ocr_service.dart';
import '../../domain/models/ocr_result.dart';
import '../../domain/models/uploaded_image.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  if (!SupabaseBootstrapConfig.isConfigured) {
    return UnconfiguredOcrService();
  }

  return SupabaseOcrService(Supabase.instance.client);
});

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  return OcrRepository(ref.watch(ocrServiceProvider));
});

final ocrControllerProvider = AsyncNotifierProvider<OcrController, OcrResult?>(
  OcrController.new,
);

class OcrController extends AsyncNotifier<OcrResult?> {
  OcrRepository get _repository => ref.read(ocrRepositoryProvider);

  @override
  OcrResult? build() {
    return null;
  }

  Future<OcrResult> extractIngredients(UploadedImage image) async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => _repository.extractIngredients(image),
    );
    state = nextState;

    if (nextState.hasError) {
      throw nextState.error!;
    }

    return nextState.requireValue;
  }

  void clear() {
    state = const AsyncData(null);
  }
}
