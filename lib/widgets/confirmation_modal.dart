
import 'dart:io';
import 'package:flutter/material.dart';

class ConfirmationModal extends StatelessWidget {
  final File imageFile;
  final void Function() onRetake;
  final void Function(String) onConfirm;

  const ConfirmationModal({
    super.key,
    required this.imageFile,
    required this.onRetake,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400), // evita ficar esmagado
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(imageFile, height: 150),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nome do usuário"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetake,
                      child: const Text("Tirar outra"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onConfirm(_nameController.text),
                      child: const Text("Cadastrar"),
                    ),
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
