import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sehat_sathi/features/scanner/data/repositories/image_upload_repository.dart';
import 'package:sehat_sathi/features/scanner/data/services/image_picker_service.dart';
import 'package:sehat_sathi/features/scanner/data/services/image_upload_service.dart';
import 'package:sehat_sathi/features/scanner/domain/models/selected_image.dart';
import 'package:sehat_sathi/features/scanner/domain/models/uploaded_image.dart';
import 'package:sehat_sathi/features/scanner/presentation/providers/image_upload_providers.dart';

void main() {
  group('ImageUploadController', () {
    test('pickFromCamera stores preview image', () async {
      final image = SelectedImage(
        name: 'camera.jpg',
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
      );

      final container = ProviderContainer(
        overrides: [
          imageUploadRepositoryProvider.overrideWithValue(
            ImageUploadRepository(
              FakeImagePickerService(cameraImage: image),
              FakeImageUploadService(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(imageUploadControllerProvider.notifier)
          .pickFromCamera();

      final state = container.read(imageUploadControllerProvider);
      expect(state.selectedImage?.name, 'camera.jpg');
      expect(state.errorMessage, isNull);
    });

    test('uploadSelectedImage returns uploaded image', () async {
      final image = SelectedImage(
        name: 'gallery.jpg',
        bytes: Uint8List.fromList([4, 5, 6]),
        mimeType: 'image/jpeg',
      );

      final container = ProviderContainer(
        overrides: [
          imageUploadRepositoryProvider.overrideWithValue(
            ImageUploadRepository(
              FakeImagePickerService(galleryImage: image),
              FakeImageUploadService(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(imageUploadControllerProvider.notifier);
      await notifier.pickFromGallery();
      final uploaded = await notifier.uploadSelectedImage();

      final state = container.read(imageUploadControllerProvider);
      expect(uploaded?.path, 'user-1/gallery.jpg');
      expect(state.uploadedImage?.publicUrl, 'https://example.com/gallery.jpg');
    });

    test('uploadSelectedImage sets error when nothing is selected', () async {
      final container = ProviderContainer(
        overrides: [
          imageUploadRepositoryProvider.overrideWithValue(
            ImageUploadRepository(
              FakeImagePickerService(),
              FakeImageUploadService(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(imageUploadControllerProvider.notifier)
          .uploadSelectedImage();

      expect(
        container.read(imageUploadControllerProvider).errorMessage,
        'Pick an image before uploading.',
      );
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
  @override
  Future<UploadedImage> uploadImage(SelectedImage image) async {
    return UploadedImage(
      path: 'user-1/${image.name}',
      publicUrl: 'https://example.com/${image.name}',
    );
  }
}
