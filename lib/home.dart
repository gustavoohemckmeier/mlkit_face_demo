
import 'package:face_detect_beta/screens/face_verification_screen.dart';
import 'package:face_detect_beta/screens/register_face_screen.dart';
import 'package:face_detect_beta/screens/validate_face_screen.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reconhecimento Facial")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const FaceVerificationScreen(),
                ));
              },
              child: const Text("Verificar Rosto (Online)"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const RegisterFaceScreen(),
                ));
              },
              child: const Text("Cadastrar Imagem Facial"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const ValidateFaceScreen(),
                ));
              },
              child: const Text("Validar Rosto (Offline)"),
            ),
          ],
        ),
      ),
    );
  }
}