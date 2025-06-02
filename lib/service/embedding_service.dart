
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

const int WIDTH = 112;
const int HEIGHT = 112;

class EmbeddingService {
  static const modelPath = 'assets/models/mobilefacenet.tflite';
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(modelPath);
  }

  Future<List<double>> getEmbedding(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes())!;
    final input = imageToArray(image);

    var output = List.generate(1, (_) => List.filled(192, 0.0));
    _interpreter.run(input.reshape([1, HEIGHT, WIDTH, 3]), output);

    return List<double>.from(output[0]);
  }

  Float32List imageToArray(img.Image inputImage) {
    final img.Image resizedImage = img.copyResize(inputImage, width: WIDTH, height: HEIGHT);

    final Float32List reshapedArray = Float32List(WIDTH * HEIGHT * 3);
    int pixelIndex = 0;

    for (int y = 0; y < HEIGHT; y++) {
      for (int x = 0; x < WIDTH; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        reshapedArray[pixelIndex++] = (r - 127.5) / 127.5;
        reshapedArray[pixelIndex++] = (g - 127.5) / 127.5;
        reshapedArray[pixelIndex++] = (b - 127.5) / 127.5;
      }
    }

    return reshapedArray;
  }

  void dispose() {
    _interpreter.close();
  }
}