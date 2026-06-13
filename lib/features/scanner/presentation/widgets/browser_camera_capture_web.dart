import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../../domain/models/selected_image.dart';

Future<SelectedImage?> showBrowserCameraCaptureDialog(BuildContext context) {
  return showDialog<SelectedImage>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _BrowserCameraCaptureDialog(),
  );
}

class _BrowserCameraCaptureDialog extends StatefulWidget {
  const _BrowserCameraCaptureDialog();

  @override
  State<_BrowserCameraCaptureDialog> createState() =>
      _BrowserCameraCaptureDialogState();
}

class _BrowserCameraCaptureDialogState
    extends State<_BrowserCameraCaptureDialog> {
  late final String _viewType;
  late final html.VideoElement _videoElement;
  html.MediaStream? _stream;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _viewType = 'browser-camera-${DateTime.now().microsecondsSinceEpoch}';
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..setAttribute('autoplay', 'true')
      ..setAttribute('playsinline', 'true');

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      return _videoElement;
    });

    unawaited(_startCamera());
  }

  Future<void> _startCamera() async {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        throw StateError('Camera access is not available in this browser.');
      }

      _stream = await mediaDevices.getUserMedia({
        'video': {
          'facingMode': 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      });

      _videoElement.srcObject = _stream;
      await _videoElement.play();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Unable to access your camera. Check browser permission and try again.';
        });
      }
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final width = _videoElement.videoWidth;
      final height = _videoElement.videoHeight;
      if (width == 0 || height == 0) {
        throw StateError('Camera preview is not ready yet.');
      }

      final canvas = html.CanvasElement(width: width, height: height);
      canvas.context2D.drawImageScaled(_videoElement, 0, 0, width, height);

      final blob = await canvas.toBlob('image/jpeg', 0.92);

      final reader = html.FileReader();
      final completer = Completer<Uint8List>();

      reader.onLoad.listen((_) {
        final result = reader.result;
        if (result is ByteBuffer) {
          completer.complete(Uint8List.view(result));
        } else if (result is Uint8List) {
          completer.complete(result);
        } else if (result is List<int>) {
          completer.complete(Uint8List.fromList(result));
        } else {
          completer.completeError(
            StateError('Could not read captured image bytes.'),
          );
        }
      });

      reader.onError.listen((_) {
        completer.completeError(
          StateError('Could not read captured image bytes.'),
        );
      });

      reader.readAsArrayBuffer(blob);
      final bytes = await completer.future;

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        SelectedImage(
          name: 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
          bytes: bytes,
          mimeType: 'image/jpeg',
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceFirst('Bad state: ', '');
        });
      }
    }
  }

  void _stopCamera() {
    final stream = _stream;
    if (stream == null) {
      return;
    }

    for (final track in stream.getTracks()) {
      track.stop();
    }
    _stream = null;
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 720,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Take a Photo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Allow browser camera access, frame the ingredient label, and capture a still photo.',
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 420,
                  width: double.infinity,
                  color: Colors.black,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : HtmlElementView(viewType: _viewType),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isLoading || _errorMessage != null
                        ? null
                        : _capturePhoto,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Capture'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
