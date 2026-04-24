import 'package:flutter/material.dart';

import '../models/publicacao.dart';
import '../widgets/publicacao_card.dart';

class SolicitacoesPage extends StatelessWidget {
  const SolicitacoesPage({super.key, required this.publicacoes});

  final List<Publicacao> publicacoes;

  @override
  Widget build(BuildContext context) {
    if (publicacoes.isEmpty) {
      return const Center(child: Text('Nenhuma solicitação cadastrada.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: publicacoes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = publicacoes[index];
        return PublicacaoCard(publicacao: p);
      },
    );
  }
}

