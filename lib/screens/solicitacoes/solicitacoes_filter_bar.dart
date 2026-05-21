import 'package:flutter/material.dart';

import 'filtro_data.dart';

class SolicitacoesFilterBar extends StatelessWidget {
  const SolicitacoesFilterBar({
    super.key,
    required this.busca,
    required this.filtroData,
    required this.onAbrirBusca,
    required this.onLimparBusca,
    required this.onFiltroChanged,
  });

  final String busca;
  final FiltroData filtroData;
  final VoidCallback onAbrirBusca;
  final VoidCallback onLimparBusca;
  final ValueChanged<FiltroData> onFiltroChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: onAbrirBusca,
            icon: const Icon(Icons.search),
            label: Text(busca.isEmpty ? 'Buscar' : 'Buscar: $busca'),
          ),
          DropdownButton<FiltroData>(
            value: filtroData,
            items: FiltroData.values
                .map(
                  (f) => DropdownMenuItem<FiltroData>(
                    value: f,
                    child: Text(f.label),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) onFiltroChanged(value);
            },
          ),
          if (busca.isNotEmpty)
            IconButton(
              onPressed: onLimparBusca,
              icon: const Icon(Icons.clear),
              tooltip: 'Limpar busca',
            ),
        ],
      ),
    );
  }
}
