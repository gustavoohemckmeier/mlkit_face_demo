import 'package:face_detect_beta/main.dart';
import 'package:face_detect_beta/service/api_service.dart';
import 'package:face_detect_beta/service/camera_service.dart';
import 'package:face_detect_beta/service/face_detector_service.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  final _cameraService = CameraService();
  final _faceDetectorService = FaceDetectorService();

  bool _isCameraInitialized = false;
  bool _faceFound = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _cameraService.initialize(cameras);
    await _cameraService.startImageStream((image) async {
      final detected = await _faceDetectorService.detectFace(image);
      if (detected != _faceFound) {
        setState(() => _faceFound = detected);
      }

      if (detected && !_isProcessing) {
        print('aqui adsada');
        _isProcessing = true;
        await ApiService.sendCapturedImageToApi(_cameraService);
        _isProcessing = false;
      }
      if (detected != _faceFound) {
        setState(() => _faceFound = detected);
      }
    });
    setState(() => _isCameraInitialized = true);
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
        children: [
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraService.controller.value.previewSize!.height,
                height: _cameraService.controller.value.previewSize!.width,
                child: CameraPreview(_cameraService.controller),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _faceFound ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _faceFound ? 'Rosto detectado!' : 'Nenhum rosto',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}