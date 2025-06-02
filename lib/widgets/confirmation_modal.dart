import 'dart:io';
import 'package:flutter/material.dart';

class ConfirmationModal extends StatelessWidget {
  final File imageFile;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;

  const ConfirmationModal({
    super.key,
    required this.imageFile,
    required this.onRetake,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirmar Imagem"),
      content: Image.file(imageFile),
      actions: [
        TextButton(
          onPressed: onRetake,
          child: const Text("Retirar Outra"),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text("Cadastrar Imagem"),
        ),
      ],
    );
  }
}