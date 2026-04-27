import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/local_database.dart';
import '../models/publicacao.dart';
import 'anuncios_page.dart';
import 'criar_page.dart';
import 'main_nav_bar_seed.dart';
import 'perfil_page.dart';
import 'solicitacoes_page.dart';

class MainNavBar extends StatefulWidget {
  const MainNavBar({super.key});

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  static const String _userId = 'local_user';

  int _currentIndex = 1;

  final List<Publicacao> _publicacoes = [];
  bool _isLoading = true;
  String _nomePerfil = 'Seu nome';
  Uint8List? _fotoPerfil;
  Timer? _loadingFallbackTimer;

  static const List<String> _titles = [
    'Solicitações',
    'Home Page',
    'Criar',
    'Carteira',
    'Perfil',
  ];

  @override
  void initState() {
    super.initState();
    _carregarPublicacoes();
  }

  @override
  void dispose() {
    _loadingFallbackTimer?.cancel();
    super.dispose();
  }

  void _iniciarFallbackSeTravou() {
    _loadingFallbackTimer?.cancel();
    _loadingFallbackTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || !_isLoading) return;
      final now = DateTime.now();
      final fallback = <Publicacao>[
        ...gerarPublicacoesFicticiasInstantanea(now),
        ...gerarPublicacoesFicticiasDoUsuarioInstantanea(
          now: now,
          userId: _userId,
          userName: _nomePerfil,
        ),
      ];
      setState(() {
        _publicacoes
          ..clear()
          ..addAll(fallback);
        _isLoading = false;
      });
    });
  }

  Future<List<Publicacao>> _listarPublicacoesComTimeout() {
    return LocalDatabase.instance
        .listarPublicacoes()
        .timeout(const Duration(seconds: 1));
  }

  bool _temPublicacoesSeed(List<Publicacao> lista) {
    return lista.any((p) => p.criadoPorId == seedUserId);
  }

  bool _temPublicacoesDoUsuario(List<Publicacao> lista) {
    return lista.any((p) => p.criadoPorId == _userId);
  }

  bool _temAnuncioSeedComImagem(List<Publicacao> lista) {
    return lista.any(
      (p) =>
          p.criadoPorId == seedUserId &&
          p.tipo == PublicacaoTipo.anuncio &&
          p.imagens.isNotEmpty,
    );
  }

  Future<List<Publicacao>> _carregarPublicacoesPersistidas() async {
    var lista = await _listarPublicacoesComTimeout();
    if (!_temPublicacoesSeed(lista)) {
      await inserirPublicacoesFicticias(LocalDatabase.instance);
      lista = await _listarPublicacoesComTimeout();
    }

    if (!_temAnuncioSeedComImagem(lista)) {
      await inserirAnunciosFicticiosComImagens(LocalDatabase.instance);
      lista = await _listarPublicacoesComTimeout();
    }

    if (!_temPublicacoesDoUsuario(lista)) {
      await inserirPublicacoesFicticiasDoUsuario(
        database: LocalDatabase.instance,
        userId: _userId,
        userName: _nomePerfil,
      );
      lista = await _listarPublicacoesComTimeout();
    }

    return lista;
  }

  void _atualizarPublicacoes(List<Publicacao> lista) {
    setState(() {
      _publicacoes
        ..clear()
        ..addAll(lista);
      _isLoading = false;
    });
  }

  void _mostrarSnackBancoIndisponivel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Banco local indisponível. Exibindo dados fictícios.'),
      ),
    );
  }

  Future<void> _carregarPublicacoes() async {
    _iniciarFallbackSeTravou();
    try {
      final lista = await _carregarPublicacoesPersistidas();
      if (!mounted) return;
      _atualizarPublicacoes(lista);
    } catch (_) {
      final now = DateTime.now();
      final fallback = <Publicacao>[
        ...await gerarPublicacoesFicticias(now),
        ...gerarPublicacoesFicticiasDoUsuarioInstantanea(
          now: now,
          userId: _userId,
          userName: _nomePerfil,
        ),
      ];
      if (!mounted) return;
      _atualizarPublicacoes(fallback);
      _mostrarSnackBancoIndisponivel();
    } finally {
      _loadingFallbackTimer?.cancel();
    }
  }

  void _adicionarPublicacao(Publicacao publicacao) {
    final destinoIndex =
        publicacao.tipo == PublicacaoTipo.solicitacao ? 0 : 1;
    setState(() {
      _publicacoes.insert(0, publicacao);
      _currentIndex = destinoIndex;
    });
    _salvarPublicacao(publicacao);
  }

  Future<void> _salvarPublicacao(Publicacao publicacao) async {
    try {
      await LocalDatabase.instance.inserirPublicacao(publicacao);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar no banco local.')),
      );
    }
  }

  List<Publicacao> _filtrarPorTipo(PublicacaoTipo tipo) {
    return _publicacoes.where((p) => p.tipo == tipo).toList(growable: false);
  }

  List<Publicacao> _meusAnuncios() {
    return _publicacoes
        .where(
          (p) => p.tipo == PublicacaoTipo.anuncio && p.criadoPorId == _userId,
        )
        .toList(growable: false);
  }

  List<Publicacao> _minhasSolicitacoes() {
    return _publicacoes
        .where(
          (p) =>
              p.tipo == PublicacaoTipo.solicitacao && p.criadoPorId == _userId,
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      SolicitacoesPage(publicacoes: _filtrarPorTipo(PublicacaoTipo.solicitacao)),
      AnunciosPage(publicacoes: _filtrarPorTipo(PublicacaoTipo.anuncio)),
      CriarPage(
        onCriar: _adicionarPublicacao,
        criadoPorId: _userId,
        criadoPorNome: _nomePerfil,
      ),
      const CarteiraPage(),
      PerfilPage(
        nome: _nomePerfil,
        foto: _fotoPerfil,
        minhasSolicitacoes: _minhasSolicitacoes(),
        meusAnuncios: _meusAnuncios(),
        onNomeAlterado: (nome) => setState(() => _nomePerfil = nome),
        onFotoAlterada: (foto) => setState(() => _fotoPerfil = foto),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_titles[_currentIndex]),
        actions: _currentIndex == 1
            ? [
                IconButton(
                  key: const Key('home_top_chat_button'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abrindo chats...')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  tooltip: 'Chat',
                ),
              ]
            : null,
      ),
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Solicitações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Criar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Carteira',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class CarteiraPage extends StatefulWidget {
  const CarteiraPage({super.key});

  @override
  State<CarteiraPage> createState() => _CarteiraPageState();
}

class _CarteiraPageState extends State<CarteiraPage> {
  double _saldo = 180.75;
  bool _atualizandoSaldo = false;

  late final List<_Compra> _compras = [
    _Compra(
      nome: 'Kit de ferramentas',
      valor: 59.90,
      data: DateTime(2026, 4, 4),
    ),
    _Compra(
      nome: 'Luva de proteção',
      valor: 18.50,
      data: DateTime(2026, 4, 12),
    ),
    _Compra(
      nome: 'Botina de segurança',
      valor: 129.90,
      data: DateTime(2026, 4, 20),
    ),
  ];

  String _formatarDinheiro(double valor) {
    final negative = valor < 0;
    final abs = valor.abs();
    final fixed = abs.toStringAsFixed(2);
    final parts = fixed.split('.');
    final inteiro = parts[0];
    final centavos = parts.length > 1 ? parts[1] : '00';
    final buffer = StringBuffer();
    for (var i = 0; i < inteiro.length; i++) {
      final indexFromEnd = inteiro.length - i;
      buffer.write(inteiro[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    final prefix = negative ? '-R\$ ' : 'R\$ ';
    return '$prefix${buffer.toString()},$centavos';
  }

  String _formatarData(DateTime data) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(data.day)}/${two(data.month)}/${data.year}';
  }

  double? _parseValorDigitado(String input) {
    final cleaned =
        input.trim().replaceAll(RegExp(r'[^0-9,\.]'), '').replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  Future<void> _abrirSaque() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      final valor = await showDialog<double>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Sacar'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  hintText: 'Ex: 50,00',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final parsed = _parseValorDigitado(value ?? '');
                  if (parsed == null) return 'Informe um valor.';
                  if (parsed <= 0) return 'Informe um valor maior que zero.';
                  if (parsed > _saldo) return 'Saldo insuficiente.';
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  final isValid = formKey.currentState?.validate() ?? false;
                  if (!isValid) return;
                  final parsed = _parseValorDigitado(controller.text);
                  Navigator.of(dialogContext).pop(parsed);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final isValid = formKey.currentState?.validate() ?? false;
                  if (!isValid) return;
                  final parsed = _parseValorDigitado(controller.text);
                  Navigator.of(dialogContext).pop(parsed);
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );

      if (!mounted || valor == null) return;
      setState(() => _saldo -= valor);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saque de ${_formatarDinheiro(valor)} solicitado.')),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _atualizarSaldo() async {
    if (_atualizandoSaldo) return;
    setState(() => _atualizandoSaldo = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _atualizandoSaldo = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saldo atualizado: ${_formatarDinheiro(_saldo)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo disponível',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatarDinheiro(_saldo),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _saldo <= 0 ? null : _abrirSaque,
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Sacar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _atualizandoSaldo ? null : _atualizarSaldo,
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        _atualizandoSaldo ? 'Atualizando...' : 'Atualizar saldo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Meus itens comprados',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (_compras.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Você ainda não comprou nenhum item.'),
            ),
          )
        else
          ..._compras.map(
            (c) => Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: Text(c.nome),
                subtitle: Text(_formatarData(c.data)),
                trailing: Text(_formatarDinheiro(c.valor)),
              ),
            ),
          ),
      ],
    );
  }
}

class _Compra {
  const _Compra({
    required this.nome,
    required this.valor,
    required this.data,
  });

  final String nome;
  final double valor;
  final DateTime data;
}
