import 'package:flutter/material.dart';

import '../models/publicacao.dart';

class PublicacaoCard extends StatelessWidget {
  const PublicacaoCard({super.key, required this.publicacao});

  final Publicacao publicacao;

  @override
  Widget build(BuildContext context) {
    final titulo = publicacao.tipo == PublicacaoTipo.solicitacao
        ? 'Procura: ${publicacao.nome}'
        : 'Vende: ${publicacao.nome}';

    final precoText = 'R\$ ${publicacao.preco.toStringAsFixed(2)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    );
  }
}

