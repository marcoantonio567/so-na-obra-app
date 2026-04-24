import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/publicacao.dart';

class CriarPage extends StatefulWidget {
  const CriarPage({super.key, required this.onCriar});

  final ValueChanged<Publicacao> onCriar;

  @override
  State<CriarPage> createState() => _CriarPageState();
}

class _CriarPageState extends State<CriarPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();

  PublicacaoTipo _tipo = PublicacaoTipo.anuncio;
  final List<Uint8List> _imagens = [];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _adicionarImagens() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;

    final bytesList = await Future.wait(files.map((f) => f.readAsBytes()));
    if (!mounted) return;
    setState(() => _imagens.addAll(bytesList));
  }

  void _removerImagem(int index) {
    setState(() => _imagens.removeAt(index));
  }

  String get _labelNome =>
      _tipo == PublicacaoTipo.solicitacao ? 'Nome do que procura' : 'Produto';

  String get _labelDescricao => _tipo == PublicacaoTipo.solicitacao
      ? 'Descrição do que procura'
      : 'Descrição do produto';

  String get _labelPreco => _tipo == PublicacaoTipo.solicitacao
      ? 'Preço que pagaria (R\$)'
      : 'Preço de venda (R\$)';

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final tipoCriado = _tipo;
    final preco = double.parse(_precoController.text.replaceAll(',', '.'));

    widget.onCriar(
      Publicacao(
        tipo: tipoCriado,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        preco: preco,
        criadoEm: DateTime.now(),
        imagens: tipoCriado == PublicacaoTipo.anuncio ? _imagens : null,
      ),
    );

    setState(() => _tipo = PublicacaoTipo.anuncio);
    _formKey.currentState?.reset();
    _nomeController.clear();
    _descricaoController.clear();
    _precoController.clear();
    _imagens.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tipoCriado == PublicacaoTipo.solicitacao
              ? 'Solicitação criada!'
              : 'Anúncio criado!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<PublicacaoTipo>(
              key: ValueKey(_tipo),
              initialValue: _tipo,
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
                if (value == null) return;
                setState(() {
                  _tipo = value;
                  if (_tipo != PublicacaoTipo.anuncio) _imagens.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: _labelNome,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Preencha este campo.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricaoController,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: _labelDescricao,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Preencha este campo.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: InputDecoration(
                labelText: _labelPreco,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final raw = (value ?? '').trim();
                if (raw.isEmpty) return 'Informe um preço.';
                final normalized = raw.replaceAll(',', '.');
                final parsed = double.tryParse(normalized);
                if (parsed == null) return 'Preço inválido.';
                if (parsed <= 0) return 'O preço deve ser maior que zero.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_tipo == PublicacaoTipo.anuncio) ...[
              Text(
                'Imagens',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _adicionarImagens,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Adicionar imagens'),
              ),
              if (_imagens.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagens.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _imagens[index],
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: IconButton(
                              onPressed: () => _removerImagem(index),
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                foregroundColor: Colors.white,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: _submit,
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }
}
