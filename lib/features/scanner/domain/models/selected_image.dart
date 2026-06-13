import 'dart:typed_data';

class SelectedImage {
  const SelectedImage({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  final String name;
  final Uint8List bytes;
  final String mimeType;

  int get sizeInBytes => bytes.lengthInBytes;
}
