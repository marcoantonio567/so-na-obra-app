import 'package:flutter/material.dart';

import '../models/publicacao.dart';
import '../utils/formatters.dart';
import 'solicitacoes/filtro_data.dart';
import 'solicitacoes/solicitacao_detalhe_page.dart';
import 'solicitacoes/solicitacoes_filter_bar.dart';

class SolicitacoesPage extends StatefulWidget {
  const SolicitacoesPage({super.key, required this.publicacoes});

  final List<Publicacao> publicacoes;

  @override
  State<SolicitacoesPage> createState() => _SolicitacoesPageState();
}

class _SolicitacoesPageState extends State<SolicitacoesPage> {
  String _busca = '';
  FiltroData _filtroData = FiltroData.todas;

  List<Publicacao> get _filtradas {
    return widget.publicacoes
        .where((p) => _matchBusca(p) && _matchData(p))
        .toList(growable: false);
  }

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.publicacoes.isEmpty) {
      return const _SolicitacoesEmptyState(
        icon: Icons.assignment_outlined,
        title: 'Nenhuma solicitação cadastrada',
        message:
            'Quando alguém procurar materiais, as solicitações aparecem aqui.',
      );
    }

    final lista = _filtradas;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.55),
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitações da obra',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.publicacoes.length} pedidos de materiais e serviços',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SolicitacoesFilterBar(
          busca: _busca,
          filtroData: _filtroData,
          onBuscaChanged: (value) => setState(() => _busca = value.trim()),
          onLimparBusca: () => setState(() => _busca = ''),
          onFiltroChanged: (value) => setState(() => _filtroData = value),
        ),
        Expanded(
          child: lista.isEmpty
              ? const _SolicitacoesEmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'Nada encontrado',
                  message: 'Tente limpar a busca ou mudar o período do filtro.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  itemCount: lista.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final publicacao = lista[index];
                    return _SolicitacaoCard(
                      publicacao: publicacao,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                SolicitacaoDetalhePage(publicacao: publicacao),
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

class _SolicitacaoCard extends StatelessWidget {
  const _SolicitacaoCard({required this.publicacao, required this.onTap});

  final Publicacao publicacao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SolicitacaoThumb(publicacao: publicacao),
              const SizedBox(width: 12),
              Expanded(
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
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      publicacao.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          icon: Icons.payments_outlined,
                          text: formatMoneyBRL(publicacao.preco),
                          emphasized: true,
                        ),
                        _InfoPill(
                          icon: Icons.person_outline,
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
      ),
    );
  }
}

class _SolicitacaoThumb extends StatelessWidget {
  const _SolicitacaoThumb({required this.publicacao});

  final Publicacao publicacao;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (publicacao.imagens.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(
          publicacao.imagens.first,
          width: 86,
          height: 86,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.construction_outlined,
        color: colorScheme.onSecondaryContainer,
        size: 32,
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
            constraints: const BoxConstraints(maxWidth: 150),
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

class _SolicitacoesEmptyState extends StatelessWidget {
  const _SolicitacoesEmptyState({
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
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
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
