import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
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
      ),
    );

    setState(() => _tipo = PublicacaoTipo.anuncio);
    _formKey.currentState?.reset();
    _nomeController.clear();
    _descricaoController.clear();
    _precoController.clear();

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
                setState(() => _tipo = value);
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

