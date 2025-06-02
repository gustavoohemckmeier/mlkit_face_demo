import 'package:camera/camera.dart';

class CameraService {
  late CameraController _cameraController;
  bool _isInitialized = false;

  CameraController get controller => _cameraController;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(List<CameraDescription> cameras) async {
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    _isInitialized = true;
  }

  Future<void> startImageStream(Function(CameraImage) onImage) async {
    await _cameraController.startImageStream(onImage);
  }

  Future<void> stopImageStream() async {
    await _cameraController.stopImageStream();
  }

  Future<XFile?> captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return await _cameraController!.takePicture();
    }
    return null;
  }
  void dispose() {
    _cameraController.dispose();
  }
}
