import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/publicacao.dart';
import 'perfil/perfil_header_card.dart';
import 'perfil/pin_recebimento_card.dart';
import 'perfil/pin_recebimento_store.dart';
import 'perfil/publicacoes_section.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({
    super.key,
    required this.userId,
    required this.nome,
    required this.foto,
    required this.onNomeAlterado,
    required this.onFotoAlterada,
    required this.minhasSolicitacoes,
    required this.meusAnuncios,
  });

  final String userId;
  final String nome;
  final Uint8List? foto;
  final ValueChanged<String> onNomeAlterado;
  final ValueChanged<Uint8List?> onFotoAlterada;
  final List<Publicacao> minhasSolicitacoes;
  final List<Publicacao> meusAnuncios;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? _pinRecebimento;
  bool _pinVisivel = false;
  bool _carregandoPin = true;
  int _publicacoesTabIndex = 0;

  PinRecebimentoStore get _pinStore =>
      PinRecebimentoStore(userId: widget.userId);

  @override
  void initState() {
    super.initState();
    _carregarPin();
  }

  Future<void> _carregarPin() async {
    setState(() => _carregandoPin = true);
    String? pin;
    try {
      pin = await _pinStore.carregar();
    } catch (_) {
      pin = null;
    }
    if (!mounted) return;
    setState(() {
      _pinRecebimento = pin;
      _carregandoPin = false;
    });
  }

  Future<void> _gerarOuRegenerarPin() async {
    setState(() => _carregandoPin = true);
    final result = await _pinStore.gerarESalvar();

    if (!mounted) return;
    setState(() {
      _carregandoPin = false;
      _pinRecebimento = result.pin;
      _pinVisivel = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message ??
              (result.savedPersistently
                  ? 'PIN gerado e salvo com sucesso.'
                  : 'PIN gerado (não foi possível salvar).'),
        ),
      ),
    );
  }

  Future<void> _copiarPin() async {
    final pin = _pinRecebimento;
    if (pin == null || pin.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: pin));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PIN copiado.')));
  }

  Future<void> _trocarFoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    widget.onFotoAlterada(bytes);
  }

  String? _validarNome(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe um nome.';
    if (text.length < 2) return 'Nome muito curto.';
    return null;
  }

  void _confirmarNovoNome({
    required BuildContext dialogContext,
    required GlobalKey<FormState> formKey,
    required TextEditingController controller,
  }) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    Navigator.of(dialogContext).pop(controller.text.trim());
  }

  Future<String?> _pedirNovoNome(String nomeAtual) async {
    final controller = TextEditingController(text: nomeAtual);
    final formKey = GlobalKey<FormState>();
    try {
      return showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Trocar nome'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: _validarNome,
                onFieldSubmitted: (_) => _confirmarNovoNome(
                  dialogContext: dialogContext,
                  formKey: formKey,
                  controller: controller,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => _confirmarNovoNome(
                  dialogContext: dialogContext,
                  formKey: formKey,
                  controller: controller,
                ),
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _editarNome() async {
    final novoNome = await _pedirNovoNome(widget.nome);
    final trimmed = (novoNome ?? '').trim();
    if (trimmed.isEmpty) return;
    widget.onNomeAlterado(trimmed);
  }

  Widget _buildPublicacoesTabs() {
    final tabs = [
      (
        label: 'Minhas solicitações',
        count: widget.minhasSolicitacoes.length,
        section: PublicacoesSection(
          titulo: 'Minhas solicitações',
          emptyText: 'Você ainda não publicou nenhuma solicitação.',
          publicacoes: widget.minhasSolicitacoes,
          mostrarCabecalho: false,
        ),
      ),
      (
        label: 'Meus anúncios',
        count: widget.meusAnuncios.length,
        section: PublicacoesSection(
          titulo: 'Meus anúncios',
          emptyText: 'Você ainda não publicou nenhum anúncio.',
          publicacoes: widget.meusAnuncios,
          mostrarCabecalho: false,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          tabs: [
            for (final tab in tabs)
              Tab(child: FittedBox(child: Text('${tab.label} (${tab.count})'))),
          ],
          onTap: (index) {
            setState(() => _publicacoesTabIndex = index);
          },
        ),
        const SizedBox(height: 12),
        tabs[_publicacoesTabIndex].section,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomeExibicao = widget.nome.trim().isEmpty ? 'Seu nome' : widget.nome;

    return DefaultTabController(
      length: 2,
      initialIndex: _publicacoesTabIndex,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PerfilHeaderCard(
            nome: nomeExibicao,
            foto: widget.foto,
            onTrocarFoto: _trocarFoto,
            onRemoverFoto: () => widget.onFotoAlterada(null),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Nome'),
              subtitle: Text(nomeExibicao),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _editarNome,
            ),
          ),
          const SizedBox(height: 12),
          PinRecebimentoCard(
            pin: _pinRecebimento,
            carregando: _carregandoPin,
            visivel: _pinVisivel,
            onCopiar: _copiarPin,
            onGerarOuRegenerar: _gerarOuRegenerarPin,
            onAlternarVisibilidade: () {
              setState(() => _pinVisivel = !_pinVisivel);
            },
          ),
          const SizedBox(height: 16),
          _buildPublicacoesTabs(),
        ],
      ),
    );
  }
}
