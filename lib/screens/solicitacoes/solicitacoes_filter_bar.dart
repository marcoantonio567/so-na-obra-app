import 'package:flutter/material.dart';

import 'filtro_data.dart';

class SolicitacoesFilterBar extends StatefulWidget {
  const SolicitacoesFilterBar({
    super.key,
    required this.busca,
    required this.filtroData,
    required this.onBuscaChanged,
    required this.onLimparBusca,
    required this.onFiltroChanged,
  });

  final String busca;
  final FiltroData filtroData;
  final ValueChanged<String> onBuscaChanged;
  final VoidCallback onLimparBusca;
  final ValueChanged<FiltroData> onFiltroChanged;

  @override
  State<SolicitacoesFilterBar> createState() => _SolicitacoesFilterBarState();
}

class _SolicitacoesFilterBarState extends State<SolicitacoesFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.busca);
  }

  @override
  void didUpdateWidget(covariant SolicitacoesFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.busca != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.busca,
        selection: TextSelection.collapsed(offset: widget.busca.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            onChanged: widget.onBuscaChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar por material, obra ou solicitante',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.busca.isEmpty
                  ? null
                  : IconButton(
                      onPressed: widget.onLimparBusca,
                      icon: const Icon(Icons.close),
                      tooltip: 'Limpar busca',
                    ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: FiltroData.values
                  .map((filtro) {
                    final selected = filtro == widget.filtroData;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: selected,
                        label: Text(filtro.label),
                        avatar: selected
                            ? const Icon(Icons.check, size: 18)
                            : const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                              ),
                        onSelected: (_) => widget.onFiltroChanged(filtro),
                        showCheckmark: false,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}
