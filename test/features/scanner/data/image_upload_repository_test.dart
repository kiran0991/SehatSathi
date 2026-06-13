import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_sathi/features/scanner/data/repositories/image_upload_repository.dart';
import 'package:sehat_sathi/features/scanner/data/services/image_picker_service.dart';
import 'package:sehat_sathi/features/scanner/data/services/image_upload_service.dart';
import 'package:sehat_sathi/features/scanner/domain/models/selected_image.dart';
import 'package:sehat_sathi/features/scanner/domain/models/uploaded_image.dart';

void main() {
  group('ImageUploadRepository', () {
    test('returns selected image from gallery picker', () async {
      final image = SelectedImage(
        name: 'label.jpg',
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
      );

      final repository = ImageUploadRepository(
        FakeImagePickerService(galleryImage: image),
        FakeImageUploadService(),
      );

      final result = await repository.pickFromGallery();

      expect(result?.name, 'label.jpg');
    });

    test('uploads selected image through service', () async {
      final image = SelectedImage(
        name: 'label.jpg',
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
      );

      final uploadService = FakeImageUploadService();
      final repository = ImageUploadRepository(
        FakeImagePickerService(),
        uploadService,
      );

      final result = await repository.uploadImage(image);

      expect(result.path, 'user-1/label.jpg');
      expect(uploadService.lastUploaded?.name, 'label.jpg');
    });
  });
}

class FakeImagePickerService implements ImagePickerService {
  FakeImagePickerService({this.cameraImage, this.galleryImage});

  final SelectedImage? cameraImage;
  final SelectedImage? galleryImage;

  @override
  Future<SelectedImage?> pickFromCamera() async => cameraImage;

  @override
  Future<SelectedImage?> pickFromGallery() async => galleryImage;
}

class FakeImageUploadService implements ImageUploadService {
  SelectedImage? lastUploaded;

  @override
  Future<UploadedImage> uploadImage(SelectedImage image) async {
    lastUploaded = image;
    return const UploadedImage(
      path: 'user-1/label.jpg',
      publicUrl: 'https://example.com/label.jpg',
    );
  }
}
