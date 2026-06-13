import '../../domain/models/selected_image.dart';
import '../../domain/models/uploaded_image.dart';
import '../services/image_picker_service.dart';
import '../services/image_upload_service.dart';

class ImageUploadRepository {
  const ImageUploadRepository(this._pickerService, this._uploadService);

  final ImagePickerService _pickerService;
  final ImageUploadService _uploadService;

  Future<SelectedImage?> pickFromCamera() => _pickerService.pickFromCamera();

  Future<SelectedImage?> pickFromGallery() => _pickerService.pickFromGallery();

  Future<UploadedImage> uploadImage(SelectedImage image) {
    return _uploadService.uploadImage(image);
  }
}
