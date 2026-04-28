import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_database.dart';
import '../models/publicacao.dart';
import '../widgets/publicacao_card.dart';

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
  static final Map<String, String> _pinMemCache = {};

  String? _pinRecebimento;
  bool _pinVisivel = false;
  bool _carregandoPin = true;

  String get _pinPrefsKey => 'pin_recebimento:${widget.userId}';

  @override
  void initState() {
    super.initState();
    _carregarPin();
  }

  Future<void> _carregarPin() async {
    setState(() => _carregandoPin = true);
    String? pin;
    try {
      if (kIsWeb) {
        try {
          final prefs = await SharedPreferences.getInstance();
          pin = prefs.getString(_pinPrefsKey);
          if ((pin ?? '').trim().isEmpty) pin = null;
        } catch (_) {
          pin = _pinMemCache[widget.userId];
        }
      } else {
        try {
          final prefs = await SharedPreferences.getInstance();
          pin = prefs.getString(_pinPrefsKey);
          if ((pin ?? '').trim().isEmpty) pin = null;
        } catch (_) {
          pin = null;
        }

        if (pin == null) {
          try {
            pin = await LocalDatabase.instance
                .obterPinRecebimento(userId: widget.userId);
            if ((pin ?? '').trim().isEmpty) pin = null;
          } catch (_) {
            pin = null;
          }

          if (pin != null) {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_pinPrefsKey, pin);
            } catch (_) {}
          }
        }
      }
    } catch (_) {
      pin = null;
    }
    if (!mounted) return;
    setState(() {
      _pinRecebimento = pin;
      _carregandoPin = false;
    });
  }

  String _gerarPin() {
    Random rng;
    try {
      rng = Random.secure();
    } catch (_) {
      rng = Random();
    }
    final n = rng.nextInt(1000000);
    return n.toString().padLeft(6, '0');
  }

  Future<void> _gerarOuRegenerarPin() async {
    final novo = _gerarPin();
    setState(() => _carregandoPin = true);
    String? message;
    var savedPersistently = false;

    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        savedPersistently = await prefs.setString(_pinPrefsKey, novo);
      } catch (_) {
        savedPersistently = false;
      }

      if (!savedPersistently) {
        _pinMemCache[widget.userId] = novo;
        message =
            'No navegador, não foi possível salvar nos dados do site. Verifique se o Edge está bloqueando cookies/dados do site (ou modo InPrivate).';
      }
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        savedPersistently = await prefs.setString(_pinPrefsKey, novo);
      } catch (_) {
        savedPersistently = false;
      }

      try {
        await LocalDatabase.instance
            .salvarPinRecebimento(userId: widget.userId, pin: novo);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _carregandoPin = false;
      _pinRecebimento = novo;
      _pinVisivel = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ??
              (savedPersistently
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN copiado.')),
    );
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

  @override
  Widget build(BuildContext context) {
    final nomeExibicao = widget.nome.trim().isEmpty ? 'Seu nome' : widget.nome;
    final pin = _pinRecebimento;
    final pinMascara = pin == null ? '—' : '••••••';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundImage:
                      widget.foto != null ? MemoryImage(widget.foto!) : null,
                  child: widget.foto == null
                      ? const Icon(Icons.person, size: 34)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeExibicao,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _trocarFoto,
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Trocar foto'),
                          ),
                          if (widget.foto != null)
                            OutlinedButton.icon(
                              onPressed: () => widget.onFotoAlterada(null),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remover'),
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
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Nome'),
                subtitle: Text(nomeExibicao),
                trailing: const Icon(Icons.edit_outlined),
                onTap: _editarNome,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PIN de recebimento',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (pin != null)
                      IconButton(
                        onPressed: _copiarPin,
                        icon: const Icon(Icons.copy_outlined),
                        tooltip: 'Copiar',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _carregandoPin
                              ? 'Carregando...'
                              : (pin == null
                                  ? 'Nenhum PIN gerado ainda.'
                                  : (_pinVisivel ? pin : pinMascara)),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (pin != null && !_carregandoPin)
                        IconButton(
                          onPressed: () =>
                              setState(() => _pinVisivel = !_pinVisivel),
                          icon: Icon(
                            _pinVisivel
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          tooltip: _pinVisivel ? 'Ocultar' : 'Mostrar',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use este PIN para confirmar o recebimento da mercadoria.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _carregandoPin ? null : _gerarOuRegenerarPin,
                      icon: Icon(pin == null ? Icons.key : Icons.refresh),
                      label: Text(pin == null ? 'Gerar PIN' : 'Gerar novo PIN'),
                    ),
                    if (pin != null)
                      OutlinedButton.icon(
                        onPressed: _carregandoPin ? null : _copiarPin,
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Copiar'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Minhas solicitações',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text('${widget.minhasSolicitacoes.length}'),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.minhasSolicitacoes.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Você ainda não publicou nenhuma solicitação.'),
            ),
          )
        else
          ...widget.minhasSolicitacoes.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PublicacaoCard(publicacao: p),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Meus anúncios',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text('${widget.meusAnuncios.length}'),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.meusAnuncios.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Você ainda não publicou nenhum anúncio.'),
            ),
          )
        else
          ...widget.meusAnuncios.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PublicacaoCard(publicacao: p),
            ),
          ),
      ],
    );
  }
}
