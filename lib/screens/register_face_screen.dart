
import 'dart:io';
import 'package:face_detect_beta/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

import '../service/camera_service.dart';
import '../service/face_detector_service.dart';
import '../service/embedding_service.dart';
import '../service/sqlite_service.dart';
import '../widgets/confirmation_modal.dart';

class RegisterFaceScreen extends StatefulWidget {
  const RegisterFaceScreen({super.key});

  @override
  State<RegisterFaceScreen> createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> {
  final CameraService _cameraService = CameraService();
  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  final EmbeddingService _embeddingService = EmbeddingService();
  final SqliteService _sqliteService = SqliteService();

  bool _isDetecting = false;
  bool _isCameraReady = false;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _embeddingService.loadModel();
    await _sqliteService.init();
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initialize(cameras);
    setState(() {
      _isCameraReady = true;
    });
    _detectFace();
  }

  void _detectFace() {
    if (_cameraService.controller == null) return;

    _cameraService.controller!.startImageStream((cameraImage) async {
      if (_isDetecting) return;

      _isDetecting = true;
      final hasFace = await _faceDetectorService.detectFace(cameraImage);

      if (hasFace) {
        _cameraService.controller!.stopImageStream();
        final xfile = await _cameraService.captureImage();

        if (xfile != null) {
          final file = File(xfile.path);
          setState(() {
            _capturedImage = file;
          });

          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => ConfirmationModal(
              imageFile: file,
              onRetake: () {
                Navigator.of(context).pop();
                _initializeCamera();
              },
              onConfirm: () async {
                final embedding = await _embeddingService.getEmbedding(file);
                final appDir = await getApplicationDocumentsDirectory();

                final imageFileName = 'face_${DateTime.now().millisecondsSinceEpoch}.jpg';
                final faceDir = Directory(p.join(appDir.path, 'face_data'));
                await faceDir.create(recursive: true);

                final savedImagePath = p.join(faceDir.path, imageFileName);
                final savedImage = await file.copy(savedImagePath);

                await _sqliteService.insertEmbedding(
                  userId: 'user_test',
                  imagePath: savedImage.path,
                  embedding: embedding,
                );

                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          );
        }
      }

      _isDetecting = false;
    });
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceDetectorService.dispose();
    _embeddingService.dispose();
    _sqliteService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Validação Facial")),
      body: _isCameraReady && (_cameraService.controller?.value.isInitialized ?? false)
          ? CameraPreview(_cameraService.controller!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

