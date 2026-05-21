import 'dart:typed_data';

import 'package:flutter/material.dart';

class PerfilHeaderCard extends StatelessWidget {
  const PerfilHeaderCard({
    super.key,
    required this.nome,
    required this.foto,
    required this.onTrocarFoto,
    required this.onRemoverFoto,
  });

  final String nome;
  final Uint8List? foto;
  final VoidCallback onTrocarFoto;
  final VoidCallback onRemoverFoto;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundImage: foto != null ? MemoryImage(foto!) : null,
              child: foto == null ? const Icon(Icons.person, size: 34) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onTrocarFoto,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Trocar foto'),
                      ),
                      if (foto != null)
                        OutlinedButton.icon(
                          onPressed: onRemoverFoto,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remover'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
