import 'package:flutter/material.dart';

import '../models/publicacao.dart';
import '../widgets/publicacao_card.dart';
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

  Future<void> _abrirBusca() async {
    final controller = TextEditingController(text: _busca);
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buscar solicitações'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Digite para buscar...',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(_busca),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (!mounted) return;
    setState(() => _busca = (resultado ?? '').trim());
  }

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
    if (widget.publicacoes.isEmpty) {
      return const Center(child: Text('Nenhuma solicitação cadastrada.'));
    }

    final lista = _filtradas;

    return Column(
      children: [
        SolicitacoesFilterBar(
          busca: _busca,
          filtroData: _filtroData,
          onAbrirBusca: _abrirBusca,
          onLimparBusca: () => setState(() => _busca = ''),
          onFiltroChanged: (value) => setState(() => _filtroData = value),
        ),
        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('Nenhuma solicitação encontrada.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: lista.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final publicacao = lista[index];
                    return PublicacaoCard(
                      publicacao: publicacao,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SolicitacaoDetalhePage(
                              publicacao: publicacao,
                            ),
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
