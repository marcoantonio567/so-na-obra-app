import 'package:flutter/material.dart';

import '../../models/publicacao.dart';
import '../../widgets/publicacao_card.dart';

class PublicacoesSection extends StatelessWidget {
  const PublicacoesSection({
    super.key,
    required this.titulo,
    required this.emptyText,
    required this.publicacoes,
    this.mostrarCabecalho = true,
  });

  final String titulo;
  final String emptyText;
  final List<Publicacao> publicacoes;
  final bool mostrarCabecalho;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mostrarCabecalho) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text('${publicacoes.length}'),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (publicacoes.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(emptyText),
            ),
          )
        else
          ...publicacoes.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PublicacaoCard(publicacao: p),
            ),
          ),
      ],
    );
  }
}
