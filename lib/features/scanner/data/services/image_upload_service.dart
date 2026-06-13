import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/models/selected_image.dart';
import '../../domain/models/uploaded_image.dart';

abstract class ImageUploadService {
  Future<UploadedImage> uploadImage(SelectedImage image);
}

class SupabaseImageUploadService implements ImageUploadService {
  SupabaseImageUploadService(this._client);

  final supabase.SupabaseClient _client;

  static const bucketName = 'scan-images';

  @override
  Future<UploadedImage> uploadImage(SelectedImage image) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You need to be logged in to upload an image.');
    }

    final sanitizedName = image.name.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final path =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';

    await _client.storage
        .from(bucketName)
        .uploadBinary(
          path,
          image.bytes,
          fileOptions: supabase.FileOptions(
            contentType: image.mimeType,
            upsert: false,
          ),
        );

    final publicUrl = _client.storage.from(bucketName).getPublicUrl(path);
    return UploadedImage(path: path, publicUrl: publicUrl);
  }
}

class UnconfiguredImageUploadService implements ImageUploadService {
  @override
  Future<UploadedImage> uploadImage(SelectedImage image) {
    throw StateError(
      'Supabase is not configured. Pass `SUPABASE_URL` and `SUPABASE_ANON_KEY` when running the app.',
    );
  }
}
