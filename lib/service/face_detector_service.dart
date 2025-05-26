import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
    ),
  );

  bool _isProcessing = false;
  DateTime? _lastDetectionTime;
  bool? _lastResult;

  final Duration debounceDuration = const Duration(milliseconds: 700);

  Future<bool> detectFace(CameraImage image) async {
    final now = DateTime.now();

    // Aplica debounce apenas se último resultado foi "true" (rosto detectado)
    if (_lastResult == true &&
        _lastDetectionTime != null &&
        now.difference(_lastDetectionTime!) < debounceDuration) {
      return true;
    }

    if (_isProcessing) return _lastResult ?? false;
    _isProcessing = true;
    _lastDetectionTime = now;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    final List<Face> faces = await _faceDetector.processImage(inputImage);
    _lastResult = faces.isNotEmpty;

    _isProcessing = false;
    return _lastResult!;
  }

  void dispose() {
    _faceDetector.close();
  }
}
