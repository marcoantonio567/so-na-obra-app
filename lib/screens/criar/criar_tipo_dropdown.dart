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
    return Row(
      children: [
        Expanded(
          child: _TipoOption(
            selected: tipo == PublicacaoTipo.anuncio,
            icon: Icons.storefront_outlined,
            title: 'Anúncio',
            subtitle: 'Vender produto',
            onTap: () => onChanged(PublicacaoTipo.anuncio),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TipoOption(
            selected: tipo == PublicacaoTipo.solicitacao,
            icon: Icons.assignment_outlined,
            title: 'Solicitação',
            subtitle: 'Procurar algo',
            onTap: () => onChanged(PublicacaoTipo.solicitacao),
          ),
        ),
      ],
    );
  }
}

class _TipoOption extends StatelessWidget {
  const _TipoOption({
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
        ? colorScheme.primaryContainer
        : colorScheme.surface;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    final foreground = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 106),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: selected ? 1.6 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: foreground),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle, color: colorScheme.primary),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                      ? colorScheme.onPrimaryContainer
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
