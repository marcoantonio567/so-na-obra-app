import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/publicacao.dart';
import '../../utils/formatters.dart';

class EntregaFields extends StatelessWidget {
  const EntregaFields({
    super.key,
    required this.logistica,
    required this.cepController,
    required this.valorPorKmController,
    required this.aceitaPropostas,
    required this.onLogisticaChanged,
    required this.onAceitaPropostasChanged,
  });

  final AnuncioLogistica logistica;
  final TextEditingController cepController;
  final TextEditingController valorPorKmController;
  final bool aceitaPropostas;
  final ValueChanged<AnuncioLogistica> onLogisticaChanged;
  final ValueChanged<bool> onAceitaPropostasChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _LogisticaOption(
                selected: logistica == AnuncioLogistica.retiradaLocal,
                icon: Icons.location_on_outlined,
                title: 'Retirada',
                subtitle: 'Comprador busca',
                onTap: () => onLogisticaChanged(AnuncioLogistica.retiradaLocal),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LogisticaOption(
                selected: logistica == AnuncioLogistica.entrega,
                icon: Icons.local_shipping_outlined,
                title: 'Entrega',
                subtitle: 'Você entrega',
                onTap: () => onLogisticaChanged(AnuncioLogistica.entrega),
              ),
            ),
          ],
        ),
        if (logistica == AnuncioLogistica.entrega) ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: cepController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: const InputDecoration(
              labelText: 'CEP de origem',
              hintText: 'Ex: 12345678',
              prefixIcon: Icon(Icons.pin_drop_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (_) {
              final cep = cepController.text.trim();
              if (cep.isEmpty) return 'Informe seu CEP.';
              if (cep.length != 8) return 'CEP deve ter 8 dígitos.';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: valorPorKmController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor por km',
              hintText: 'Ex: 2,50',
              prefixIcon: Icon(Icons.payments_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (_) {
              final parsed = parseMoneyInput(valorPorKmController.text);
              if (parsed == null) return 'Informe o valor por km.';
              if (parsed <= 0) return 'O valor por km deve ser maior que zero.';
              return null;
            },
          ),
        ],
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: aceitaPropostas
                ? colorScheme.secondaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: SwitchListTile(
            value: aceitaPropostas,
            onChanged: onAceitaPropostasChanged,
            secondary: Icon(
              Icons.handshake_outlined,
              color: aceitaPropostas
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            title: const Text('Aceitar propostas'),
            subtitle: const Text('Permite negociar um valor diferente.'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }
}

class _LogisticaOption extends StatelessWidget {
  const _LogisticaOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = selected
        ? colorScheme.secondaryContainer
        : colorScheme.surface;
    final foreground = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? colorScheme.secondary
                  : colorScheme.outlineVariant,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: foreground),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle, color: colorScheme.secondary),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
