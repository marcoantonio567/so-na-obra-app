import 'package:flutter/material.dart';

import '../models/publicacao.dart';
import '../utils/formatters.dart';
import 'anuncio_detalhe_page.dart';

enum _FiltroData { todas, hoje, ultimos7Dias, ultimos30Dias }

extension on _FiltroData {
  String get label {
    return switch (this) {
      _FiltroData.todas => 'Todos',
      _FiltroData.hoje => 'Hoje',
      _FiltroData.ultimos7Dias => '7 dias',
      _FiltroData.ultimos30Dias => '30 dias',
    };
  }

  int? get dias {
    return switch (this) {
      _FiltroData.todas => null,
      _FiltroData.hoje => 1,
      _FiltroData.ultimos7Dias => 7,
      _FiltroData.ultimos30Dias => 30,
    };
  }
}

class AnunciosPage extends StatefulWidget {
  const AnunciosPage({super.key, required this.publicacoes});

  final List<Publicacao> publicacoes;

  @override
  State<AnunciosPage> createState() => _AnunciosPageState();
}

class _AnunciosPageState extends State<AnunciosPage> {
  String _busca = '';
  _FiltroData _filtroData = _FiltroData.todas;

  bool _matchBusca(Publicacao p) {
    final q = _busca.trim().toLowerCase();
    if (q.isEmpty) return true;
    return p.nome.toLowerCase().contains(q) ||
        p.descricao.toLowerCase().contains(q) ||
        p.criadoPorNome.toLowerCase().contains(q);
  }

  bool _matchData(Publicacao p) {
    final dias = _filtroData.dias;
    if (dias == null) return true;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final inicio = startOfToday.subtract(Duration(days: dias - 1));
    final criado = p.criadoEm.toLocal();
    return !criado.isBefore(inicio);
  }

  List<Publicacao> get _filtradas {
    return widget.publicacoes
        .where((p) => _matchBusca(p) && _matchData(p))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.publicacoes.isEmpty) {
      return const _HomeEmptyState(
        icon: Icons.storefront_outlined,
        title: 'Nenhum anúncio cadastrado',
        message: 'Quando houver produtos à venda, eles aparecem aqui.',
      );
    }

    final lista = _filtradas;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HomeHeader(total: widget.publicacoes.length),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _FiltersHeaderDelegate(
            child: _HomeFilters(
              busca: _busca,
              filtroData: _filtroData,
              onBuscaChanged: (value) => setState(() => _busca = value.trim()),
              onLimparBusca: () => setState(() => _busca = ''),
              onFiltroChanged: (value) => setState(() => _filtroData = value),
            ),
          ),
        ),
        if (lista.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _HomeEmptyState(
              icon: Icons.search_off_outlined,
              title: 'Nenhum produto encontrado',
              message: 'Tente limpar a busca ou mudar o período do filtro.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            sliver: SliverList.separated(
              itemCount: lista.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final publicacao = lista[index];
                return _AnuncioCard(
                  publicacao: publicacao,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            AnuncioDetalhePage(publicacao: publicacao),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.72),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.storefront_outlined,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Materiais disponíveis',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  '$total anúncios para comprar ou negociar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FiltersHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 126;

  @override
  double get maxExtent => 126;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 2 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _FiltersHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _HomeFilters extends StatefulWidget {
  const _HomeFilters({
    required this.busca,
    required this.filtroData,
    required this.onBuscaChanged,
    required this.onLimparBusca,
    required this.onFiltroChanged,
  });

  final String busca;
  final _FiltroData filtroData;
  final ValueChanged<String> onBuscaChanged;
  final VoidCallback onLimparBusca;
  final ValueChanged<_FiltroData> onFiltroChanged;

  @override
  State<_HomeFilters> createState() => _HomeFiltersState();
}

class _HomeFiltersState extends State<_HomeFilters> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.busca);
  }

  @override
  void didUpdateWidget(covariant _HomeFilters oldWidget) {
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
              hintText: 'Buscar produto, vendedor ou descrição',
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
                alpha: 0.7,
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
              children: _FiltroData.values
                  .map((filtro) {
                    final selected = filtro == widget.filtroData;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: selected,
                        showCheckmark: false,
                        avatar: selected
                            ? const Icon(Icons.check, size: 18)
                            : const Icon(Icons.access_time_outlined, size: 18),
                        label: Text(filtro.label),
                        onSelected: (_) => widget.onFiltroChanged(filtro),
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

class _AnuncioCard extends StatelessWidget {
  const _AnuncioCard({required this.publicacao, required this.onTap});

  final Publicacao publicacao;
  final VoidCallback onTap;

  String get _logisticaLabel {
    final logistica =
        publicacao.anuncioLogistica ?? AnuncioLogistica.retiradaLocal;
    return logistica == AnuncioLogistica.entrega
        ? 'Faz entrega'
        : 'Retirada local';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AnuncioImage(publicacao: publicacao),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          publicacao.nome,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        formatMoneyBRL(publicacao.preco),
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    publicacao.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(
                        icon: Icons.local_shipping_outlined,
                        text: _logisticaLabel,
                        emphasized: true,
                      ),
                      if (publicacao.aceitaPropostas)
                        const _InfoPill(
                          icon: Icons.handshake_outlined,
                          text: 'Aceita proposta',
                        ),
                      _InfoPill(
                        icon: Icons.storefront_outlined,
                        text: publicacao.criadoPorNome,
                      ),
                      _InfoPill(
                        icon: Icons.calendar_today_outlined,
                        text: formatDateBR(publicacao.criadoEm),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnuncioImage extends StatelessWidget {
  const _AnuncioImage({required this.publicacao});

  final Publicacao publicacao;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (publicacao.imagens.isNotEmpty) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.memory(publicacao.imagens.first, fit: BoxFit.cover),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _Badge(
              icon: Icons.sell_outlined,
              text: 'À venda',
              background: colorScheme.tertiaryContainer,
              foreground: colorScheme.onTertiaryContainer,
            ),
          ),
          if (publicacao.imagens.length > 1)
            Positioned(
              right: 12,
              top: 12,
              child: _Badge(
                icon: Icons.photo_library_outlined,
                text: '${publicacao.imagens.length} fotos',
                background: colorScheme.surface.withValues(alpha: 0.92),
                foreground: colorScheme.onSurface,
              ),
            ),
        ],
      );
    }

    return Container(
      height: 154,
      alignment: Alignment.center,
      color: colorScheme.secondaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(height: 8),
          Text(
            'Sem imagem',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  final IconData icon;
  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = emphasized
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foreground = emphasized
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                icon,
                size: 34,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
