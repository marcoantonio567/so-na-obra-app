import 'package:flutter/material.dart';

import '../models/publicacao.dart';
import 'anuncio_detalhe_page.dart';
import '../widgets/publicacao_card.dart';

enum _FiltroData { todas, hoje, ultimos7Dias, ultimos30Dias }

extension on _FiltroData {
  String get label {
    return switch (this) {
      _FiltroData.todas => 'Todas',
      _FiltroData.hoje => 'Hoje',
      _FiltroData.ultimos7Dias => 'Últimos 7 dias',
      _FiltroData.ultimos30Dias => 'Últimos 30 dias',
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

  Future<void> _abrirBusca() async {
    final controller = TextEditingController(text: _busca);
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buscar anúncios'),
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

    if (!mounted) return;
    setState(() => _busca = (resultado ?? '').trim());
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

  List<Publicacao> get _filtradas {
    return widget.publicacoes
        .where((p) => _matchBusca(p) && _matchData(p))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.publicacoes.isEmpty) {
      return const Center(child: Text('Nenhum anúncio cadastrado.'));
    }

    final lista = _filtradas;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _abrirBusca,
                icon: const Icon(Icons.search),
                label: Text(_busca.isEmpty ? 'Buscar' : 'Buscar: $_busca'),
              ),
              DropdownButton<_FiltroData>(
                value: _filtroData,
                items: _FiltroData.values
                    .map(
                      (f) => DropdownMenuItem<_FiltroData>(
                        value: f,
                        child: Text(f.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _filtroData = value);
                },
              ),
              if (_busca.isNotEmpty)
                IconButton(
                  onPressed: () => setState(() => _busca = ''),
                  icon: const Icon(Icons.clear),
                  tooltip: 'Limpar busca',
                ),
            ],
          ),
        ),
        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('Nenhum anúncio encontrado.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: lista.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = lista[index];
                    return PublicacaoCard(
                      publicacao: p,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AnuncioDetalhePage(publicacao: p),
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
