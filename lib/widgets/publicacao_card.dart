import 'package:flutter/material.dart';

import '../models/publicacao.dart';

class PublicacaoCard extends StatelessWidget {
  const PublicacaoCard({super.key, required this.publicacao, this.onTap});

  final Publicacao publicacao;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titulo = publicacao.tipo == PublicacaoTipo.solicitacao
        ? 'Procura: ${publicacao.nome}'
        : 'Vende: ${publicacao.nome}';

    final precoText = 'R\$ ${publicacao.preco.toStringAsFixed(2)}';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (publicacao.imagens.isNotEmpty) ...[
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: publicacao.imagens.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          publicacao.imagens[index],
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    precoText,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(publicacao.descricao),
            ],
          ),
        ),
      ),
    );
  }
}
