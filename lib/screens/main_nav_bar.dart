import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/seed/publicacoes_seed.dart';
import '../models/publicacao.dart';
import '../services/publicacoes_service.dart';
import 'anuncios_page.dart';
import 'carteira/carteira_page.dart';
import 'criar_page.dart';
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

  static const PublicacoesService _publicacoesService = PublicacoesService();
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
      final lista = await _publicacoesService.carregar(
        userId: _userId,
        userName: _nomePerfil,
      );
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
      await _publicacoesService.salvar(publicacao);
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
        userId: _userId,
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
