import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_bootstrap.dart';
import '../../data/repositories/image_upload_repository.dart';
import '../../data/services/image_picker_service.dart';
import '../../data/services/image_upload_service.dart';
import '../../domain/models/image_upload_state.dart';
import '../../domain/models/selected_image.dart';
import '../../domain/models/uploaded_image.dart';

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return WebImagePickerService();
});

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  if (!SupabaseBootstrapConfig.isConfigured) {
    return UnconfiguredImageUploadService();
  }

  return SupabaseImageUploadService(Supabase.instance.client);
});

final imageUploadRepositoryProvider = Provider<ImageUploadRepository>((ref) {
  return ImageUploadRepository(
    ref.watch(imagePickerServiceProvider),
    ref.watch(imageUploadServiceProvider),
  );
});

final imageUploadControllerProvider =
    NotifierProvider<ImageUploadController, ImageUploadState>(
      ImageUploadController.new,
    );

class ImageUploadController extends Notifier<ImageUploadState> {
  ImageUploadRepository get _repository =>
      ref.read(imageUploadRepositoryProvider);

  @override
  ImageUploadState build() {
    return const ImageUploadState();
  }

  Future<void> pickFromCamera() async {
    await _pick(_repository.pickFromCamera);
  }

  Future<void> pickFromGallery() async {
    await _pick(_repository.pickFromGallery);
  }

  void setSelectedImage(SelectedImage image) {
    state = state.copyWith(
      selectedImage: image,
      clearUploadedImage: true,
      clearErrorMessage: true,
    );
  }

  Future<void> _pick(Future<SelectedImage?> Function() action) async {
    state = state.copyWith(
      isPicking: true,
      clearErrorMessage: true,
      clearUploadedImage: true,
    );

    try {
      final image = await action();
      state = state.copyWith(
        selectedImage: image,
        isPicking: false,
        clearUploadedImage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isPicking: false,
        errorMessage: error.toString().replaceFirst('Bad state: ', ''),
      );
    }
  }

  Future<UploadedImage?> uploadSelectedImage() async {
    final image = state.selectedImage;
    if (image == null) {
      state = state.copyWith(errorMessage: 'Pick an image before uploading.');
      return null;
    }

    state = state.copyWith(isUploading: true, clearErrorMessage: true);

    try {
      final uploadedImage = await _repository.uploadImage(image);
      state = state.copyWith(uploadedImage: uploadedImage, isUploading: false);
      return uploadedImage;
    } catch (error) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: error.toString().replaceFirst('Bad state: ', ''),
      );
      return null;
    }
  }

  void clearSelection() {
    state = state.copyWith(
      clearSelectedImage: true,
      clearUploadedImage: true,
      clearErrorMessage: true,
    );
  }
}
