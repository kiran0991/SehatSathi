import 'package:image_picker/image_picker.dart';

import '../../domain/models/selected_image.dart';

abstract class ImagePickerService {
  Future<SelectedImage?> pickFromCamera();

  Future<SelectedImage?> pickFromGallery();
}

class WebImagePickerService implements ImagePickerService {
  WebImagePickerService([ImagePicker? imagePicker])
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<SelectedImage?> pickFromCamera() {
    return _pick(ImageSource.camera);
  }

  @override
  Future<SelectedImage?> pickFromGallery() {
    return _pick(ImageSource.gallery);
  }

  Future<SelectedImage?> _pick(ImageSource source) async {
    final file = await _imagePicker.pickImage(source: source);
    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();
    final extension = _extension(file.name);

    return SelectedImage(
      name: file.name,
      bytes: bytes,
      mimeType: _mimeType(extension),
    );
  }

  String _extension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) {
      return '';
    }

    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _mimeType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
