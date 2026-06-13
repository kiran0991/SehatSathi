import 'selected_image.dart';
import 'uploaded_image.dart';

class ImageUploadState {
  const ImageUploadState({
    this.selectedImage,
    this.uploadedImage,
    this.isPicking = false,
    this.isUploading = false,
    this.errorMessage,
  });

  final SelectedImage? selectedImage;
  final UploadedImage? uploadedImage;
  final bool isPicking;
  final bool isUploading;
  final String? errorMessage;

  bool get hasPreview => selectedImage != null;

  ImageUploadState copyWith({
    SelectedImage? selectedImage,
    UploadedImage? uploadedImage,
    bool? isPicking,
    bool? isUploading,
    String? errorMessage,
    bool clearSelectedImage = false,
    bool clearUploadedImage = false,
    bool clearErrorMessage = false,
  }) {
    return ImageUploadState(
      selectedImage: clearSelectedImage
          ? null
          : selectedImage ?? this.selectedImage,
      uploadedImage: clearUploadedImage
          ? null
          : uploadedImage ?? this.uploadedImage,
      isPicking: isPicking ?? this.isPicking,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
