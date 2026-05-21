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

  String get _tituloHeader => _tipo == PublicacaoTipo.solicitacao
      ? 'Criar solicitação'
      : 'Criar anúncio';

  String get _subtituloHeader => _tipo == PublicacaoTipo.solicitacao
      ? 'Conte o que você procura e quanto pretende pagar.'
      : 'Cadastre um produto com preço, entrega e fotos.';

  String get _labelNome =>
      _tipo == PublicacaoTipo.solicitacao ? 'O que você procura?' : 'Produto';

  String get _labelDescricao => _tipo == PublicacaoTipo.solicitacao
      ? 'Descreva o que precisa'
      : 'Descreva o produto';

  String get _labelPreco => _tipo == PublicacaoTipo.solicitacao
      ? 'Valor que pretende pagar'
      : 'Preço de venda';

  String get _botaoCriar => _tipo == PublicacaoTipo.solicitacao
      ? 'Publicar solicitação'
      : 'Publicar anúncio';

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
    final preco = parseMoneyInput(_precoController.text);
    if (preco == null) return;

    final isEntrega =
        tipoCriado == PublicacaoTipo.anuncio &&
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
        anuncioLogistica: tipoCriado == PublicacaoTipo.anuncio
            ? _logistica
            : null,
        entregaCep: isEntrega
            ? _cepController.text.trim().replaceAll(RegExp(r'\D'), '')
            : null,
        entregaValorPorKm: isEntrega
            ? parseMoneyInput(_valorPorKmController.text)
            : null,
        aceitaPropostas: tipoCriado == PublicacaoTipo.anuncio
            ? _aceitaPropostas
            : false,
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
    setState(() {
      _tipo = PublicacaoTipo.anuncio;
      _limparCamposDeAnuncio();
    });
    _formKey.currentState?.reset();
    _nomeController.clear();
    _descricaoController.clear();
    _precoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _CreateHeader(title: _tituloHeader, subtitle: _subtituloHeader),
          const SizedBox(height: 16),
          _FormSection(
            icon: Icons.tune_outlined,
            title: 'Tipo de publicação',
            child: CriarTipoDropdown(tipo: _tipo, onChanged: _alterarTipo),
          ),
          const SizedBox(height: 14),
          _FormSection(
            icon: Icons.edit_note_outlined,
            title: 'Informações principais',
            child: Column(
              children: [
                TextFormField(
                  controller: _nomeController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: _labelNome,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validarCampoObrigatorio,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descricaoController,
                  minLines: 4,
                  maxLines: 7,
                  decoration: InputDecoration(
                    labelText: _labelDescricao,
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes_outlined),
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
                    hintText: 'Ex: 120,00',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validarPreco,
                ),
              ],
            ),
          ),
          if (_tipo == PublicacaoTipo.anuncio) ...[
            const SizedBox(height: 14),
            _FormSection(
              icon: Icons.local_shipping_outlined,
              title: 'Entrega e negociação',
              child: EntregaFields(
                logistica: _logistica,
                cepController: _cepController,
                valorPorKmController: _valorPorKmController,
                aceitaPropostas: _aceitaPropostas,
                onLogisticaChanged: _alterarLogistica,
                onAceitaPropostasChanged: (value) {
                  setState(() => _aceitaPropostas = value);
                },
              ),
            ),
            const SizedBox(height: 14),
            _FormSection(
              icon: Icons.photo_library_outlined,
              title: 'Fotos do produto',
              child: ImagensPickerSection(
                imagens: _imagens,
                onAdicionarImagens: _adicionarImagens,
                onRemoverImagem: (index) {
                  setState(() => _imagens.removeAt(index));
                },
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _submit,
            icon: const Icon(Icons.publish_outlined),
            label: Text(_botaoCriar),
          ),
        ],
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
    final parsed = parseMoneyInput(raw);
    if (parsed == null) return 'Preço inválido.';
    if (parsed <= 0) return 'O preço deve ser maior que zero.';
    return null;
  }
}

class _CreateHeader extends StatelessWidget {
  const _CreateHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
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
            child: Icon(Icons.add_box_outlined, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
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

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
