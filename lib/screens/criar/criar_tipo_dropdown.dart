import 'package:flutter/material.dart';

import '../../models/publicacao.dart';

class CriarTipoDropdown extends StatelessWidget {
  const CriarTipoDropdown({
    super.key,
    required this.tipo,
    required this.onChanged,
  });

  final PublicacaoTipo tipo;
  final ValueChanged<PublicacaoTipo> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PublicacaoTipo>(
      key: ValueKey(tipo),
      initialValue: tipo,
      decoration: const InputDecoration(
        labelText: 'O que você quer criar?',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: PublicacaoTipo.anuncio,
          child: Text('Anúncio (vender algo)'),
        ),
        DropdownMenuItem(
          value: PublicacaoTipo.solicitacao,
          child: Text('Solicitação (procurar algo)'),
        ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
