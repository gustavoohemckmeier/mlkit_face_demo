import 'package:face_detect_beta/constants/api_routes.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'camera_service.dart';

class ApiService {
  static Future<File?> captureImageFile(CameraService cameraService) async {
    if (cameraService.controller == null || !cameraService.controller!.value.isInitialized) {
      return null;
    }

    try {
      final image = await cameraService.controller!.takePicture();

      final directory = await getTemporaryDirectory();
      final imagePath = path.join(directory.path, 'captured_face.jpg');
      final imageFile = await File(image.path).copy(imagePath);

      return imageFile;
    } catch (e) {
      print("Erro ao capturar a imagem: \$e");
      return null;
    }
  }

  static Future<void> sendCapturedImageToApi(CameraService cameraService) async {
    final imagem = await captureImageFile(cameraService);
    if (imagem == null) {
      print("Imagem não foi capturada.");
      return;
    }
    final uri = Uri.parse(ApiRoutes.validateFace);
    final request = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = 'gustavo'
      ..files.add(
        await http.MultipartFile.fromPath(
          'face_img',
          imagem.path,
          filename: path.basename(imagem.path),
        ),
      );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("Imagem enviada com sucesso: \$responseBody");
      } else {
        print("Erro ao enviar imagem: \${response.statusCode} - \$responseBody");
      }
    } catch (e) {
      print("Erro ao fazer requisição: \$e");
    }
  }
}