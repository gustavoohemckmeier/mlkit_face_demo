
import 'dart:io';
import 'dart:math';
import 'package:face_detect_beta/main.dart';
import 'package:face_detect_beta/screens/face_not_recognized_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../service/camera_service.dart';
import '../service/face_detector_service.dart';
import '../service/embedding_service.dart';
import '../service/sqlite_service.dart';

class ValidateFaceScreen extends StatefulWidget {
  const ValidateFaceScreen({super.key});

  @override
  State<ValidateFaceScreen> createState() => _ValidateFaceScreenState();
}

class _ValidateFaceScreenState extends State<ValidateFaceScreen> {
  final CameraService _cameraService = CameraService();
  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  final EmbeddingService _embeddingService = EmbeddingService();
  final SqliteService _sqliteService = SqliteService();
  String nome = "";
  bool _isDetecting = false;
  String _status = "Aguardando rosto...";
  int _attempts = 0;
  final int _maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _cameraService.initialize(cameras);
    await _embeddingService.loadModel();
    await _sqliteService.init();
    _detectFace();
  }

  void _detectFace() {
    if (_cameraService.controller == null) return;

    _cameraService.controller!.startImageStream((cameraImage) async {
      if (_isDetecting) return;

      _isDetecting = true;
      // print("[DEBUG] Analisando imagem da câmera...");
      final hasFace = await _faceDetectorService.detectFace(cameraImage);
      // print("[DEBUG] Face detectada: $hasFace");

      if (hasFace) {
        _cameraService.controller!.stopImageStream();
        final xfile = await _cameraService.captureImage();

        if (xfile != null) {
          final file = File(xfile.path);
          final currentEmbedding = await _embeddingService.getEmbedding(file);

          final savedEmbeddings = await _sqliteService.getAllEmbeddingsGroupedByUser();
          // print('[DEBUG] Embeddings salvos: $savedEmbeddings');

          bool match = false;
          String matchedName = "";

          for (var entry in savedEmbeddings.entries) {
            for (var savedEmbedding in entry.value) {
              if (_compareEmbeddings(currentEmbedding, savedEmbedding)) {
                match = true;
                matchedName = entry.key;
                break;
              }
            }
            if (match) break;
          }

          setState(() {
            nome = matchedName;
            _status = match
                ? "Rosto reconhecido ✅\nUsuário: $nome"
                : "Não reconhecido ❌";
          });

          if (!match) {
            _attempts++;
            // print("[DEBUG] Tentativa $_attempts de $_maxAttempts");

            if (_attempts >= _maxAttempts) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaceNotRecognizedScreen()),
                );
              }
              return;
            }

            Future.delayed(const Duration(seconds: 2), () => _detectFace());
          }
        }
      }

      _isDetecting = false;
    });
  }

  bool _compareEmbeddings(List<double> e1, List<double> e2, [double threshold = 1.0]) {
    double sum = 0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    final distance = sqrt(sum);
    return distance < threshold;
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
      body: Column(
        children: [
          Expanded(
            child: _cameraService.controller?.value.isInitialized ?? false
                ? CameraPreview(_cameraService.controller!)
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_status, style: const TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }
}