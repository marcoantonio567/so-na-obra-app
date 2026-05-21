import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImagensPickerSection extends StatelessWidget {
  const ImagensPickerSection({
    super.key,
    required this.imagens,
    required this.onAdicionarImagens,
    required this.onRemoverImagem,
  });

  final List<Uint8List> imagens;
  final VoidCallback onAdicionarImagens;
  final ValueChanged<int> onRemoverImagem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Imagens', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAdicionarImagens,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Adicionar imagens'),
        ),
        if (imagens.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imagens.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imagens[index],
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton(
                        onPressed: () => onRemoverImagem(index),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
