import 'package:flutter/material.dart';

import '../models/compra.dart';
import '../utils/formatters.dart';

class CompraCard extends StatelessWidget {
  const CompraCard({
    super.key,
    required this.compra,
    required this.confirmEnabled,
    required this.onConfirmarRecebimento,
  });

  final Compra compra;
  final bool confirmEnabled;
  final VoidCallback onConfirmarRecebimento;

  @override
  Widget build(BuildContext context) {
    final recebidoEm = compra.recebidoEm;
    return Card(
      child: Column(
        children: [
          ListTile(
            isThreeLine: compra.recebido && recebidoEm != null,
            leading: Icon(
              compra.recebido
                  ? Icons.check_circle_outline
                  : Icons.shopping_bag_outlined,
            ),
            title: Text(compra.nome),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDateBR(compra.data)),
                if (compra.recebido && recebidoEm != null)
                  Text('Recebido em ${formatDateBR(recebidoEm)}'),
              ],
            ),
            trailing: Text(formatMoneyBRL(compra.valor)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: compra.recebido
                  ? FilledButton.tonalIcon(
                      onPressed: null,
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Recebido'),
                    )
                  : FilledButton.icon(
                      onPressed: confirmEnabled ? onConfirmarRecebimento : null,
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Confirmar recebimento'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
