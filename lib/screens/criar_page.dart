import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/publicacao.dart';
import '../utils/formatters.dart';
import 'criar/criar_tipo_dropdown.dart';
import 'criar/entrega_fields.dart';
import 'criar/imagens_picker_section.dart';

class CriarPage extends StatefulWidget {
  const CriarPage({
    super.key,
    required this.onCriar,
    required this.criadoPorId,
    required this.criadoPorNome,
  });

  final ValueChanged<Publicacao> onCriar;
  final String criadoPorId;
  final String criadoPorNome;

  @override
  State<CriarPage> createState() => _CriarPageState();
}

class _CriarPageState extends State<CriarPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _cepController = TextEditingController();
  final _valorPorKmController = TextEditingController();

  PublicacaoTipo _tipo = PublicacaoTipo.anuncio;
  AnuncioLogistica _logistica = AnuncioLogistica.retiradaLocal;
  bool _aceitaPropostas = false;
  final List<Uint8List> _imagens = [];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _cepController.dispose();
    _valorPorKmController.dispose();
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

  String get _labelNome =>
      _tipo == PublicacaoTipo.solicitacao ? 'Nome do que procura' : 'Produto';

  String get _labelDescricao => _tipo == PublicacaoTipo.solicitacao
      ? 'Descrição do que procura'
      : 'Descrição do produto';

  String get _labelPreco => _tipo == PublicacaoTipo.solicitacao
      ? 'Preço que pagaria (R\$)'
      : 'Preço de venda (R\$)';

  void _alterarTipo(PublicacaoTipo value) {
    setState(() {
      _tipo = value;
      if (_tipo != PublicacaoTipo.anuncio) _limparCamposDeAnuncio();
    });
  }

  void _alterarLogistica(AnuncioLogistica value) {
    setState(() {
      _logistica = value;
      if (_logistica != AnuncioLogistica.entrega) {
        _cepController.clear();
        _valorPorKmController.clear();
      }
    });
  }

  void _limparCamposDeAnuncio() {
    _imagens.clear();
    _cepController.clear();
    _valorPorKmController.clear();
    _logistica = AnuncioLogistica.retiradaLocal;
    _aceitaPropostas = false;
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final tipoCriado = _tipo;
    final preco = double.parse(_precoController.text.replaceAll(',', '.'));
    final isEntrega = tipoCriado == PublicacaoTipo.anuncio &&
        _logistica == AnuncioLogistica.entrega;

    widget.onCriar(
      Publicacao(
        tipo: tipoCriado,
        criadoPorId: widget.criadoPorId,
        criadoPorNome: widget.criadoPorNome,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        preco: preco,
        criadoEm: DateTime.now(),
        imagens: tipoCriado == PublicacaoTipo.anuncio ? _imagens : null,
        anuncioLogistica:
            tipoCriado == PublicacaoTipo.anuncio ? _logistica : null,
        entregaCep: isEntrega
            ? _cepController.text.trim().replaceAll(RegExp(r'\D'), '')
            : null,
        entregaValorPorKm:
            isEntrega ? parseMoneyInput(_valorPorKmController.text) : null,
        aceitaPropostas:
            tipoCriado == PublicacaoTipo.anuncio ? _aceitaPropostas : false,
      ),
    );

    _resetForm();
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

  void _resetForm() {
    setState(() => _tipo = PublicacaoTipo.anuncio);
    _formKey.currentState?.reset();
    _nomeController.clear();
    _descricaoController.clear();
    _precoController.clear();
    _limparCamposDeAnuncio();
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
            CriarTipoDropdown(tipo: _tipo, onChanged: _alterarTipo),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: _labelNome,
                border: const OutlineInputBorder(),
              ),
              validator: _validarCampoObrigatorio,
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
              validator: _validarCampoObrigatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: _labelPreco,
                border: const OutlineInputBorder(),
              ),
              validator: _validarPreco,
            ),
            const SizedBox(height: 16),
            if (_tipo == PublicacaoTipo.anuncio) ...[
              EntregaFields(
                logistica: _logistica,
                cepController: _cepController,
                valorPorKmController: _valorPorKmController,
                aceitaPropostas: _aceitaPropostas,
                onLogisticaChanged: _alterarLogistica,
                onAceitaPropostasChanged: (value) {
                  setState(() => _aceitaPropostas = value);
                },
              ),
              const SizedBox(height: 12),
              ImagensPickerSection(
                imagens: _imagens,
                onAdicionarImagens: _adicionarImagens,
                onRemoverImagem: (index) {
                  setState(() => _imagens.removeAt(index));
                },
              ),
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

  String? _validarCampoObrigatorio(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Preencha este campo.';
    return null;
  }

  String? _validarPreco(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Informe um preço.';
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null) return 'Preço inválido.';
    if (parsed <= 0) return 'O preço deve ser maior que zero.';
    return null;
  }
}
