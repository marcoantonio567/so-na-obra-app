import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/local_database.dart';
import '../models/publicacao.dart';
import 'anuncios_page.dart';
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
  static const String _seedUserId = 'seed_user';
  static const List<int> _imagemPngPlaceholder = <int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ];

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
      final fallback = _gerarPublicacoesFicticiasInstantanea(DateTime.now());
      setState(() {
        _publicacoes
          ..clear()
          ..addAll(fallback);
        _isLoading = false;
      });
    });
  }

  Future<void> _carregarPublicacoes() async {
    _iniciarFallbackSeTravou();
    try {
      var lista = await LocalDatabase.instance
          .listarPublicacoes()
          .timeout(const Duration(seconds: 1));
      if (!lista.any((p) => p.criadoPorId == _seedUserId)) {
        await _inserirPublicacoesFicticias();
        lista = await LocalDatabase.instance
            .listarPublicacoes()
            .timeout(const Duration(seconds: 1));
      } else {
        final temAnuncioComImagem = lista.any(
          (p) =>
              p.criadoPorId == _seedUserId &&
              p.tipo == PublicacaoTipo.anuncio &&
              p.imagens.isNotEmpty,
        );
        if (!temAnuncioComImagem) {
          await _inserirAnunciosFicticiosComImagens();
          lista = await LocalDatabase.instance
              .listarPublicacoes()
              .timeout(const Duration(seconds: 1));
        }
      }
      if (!mounted) return;
      setState(() {
        _publicacoes
          ..clear()
          ..addAll(lista);
        _isLoading = false;
      });
      _loadingFallbackTimer?.cancel();
    } catch (_) {
      final fallback = await _gerarPublicacoesFicticias(DateTime.now());
      if (!mounted) return;
      setState(() {
        _publicacoes
          ..clear()
          ..addAll(fallback);
        _isLoading = false;
      });
      _loadingFallbackTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Banco local indisponível. Exibindo dados fictícios.',
          ),
        ),
      );
    }
  }

  List<Publicacao> _gerarPublicacoesFicticiasInstantanea(DateTime now) {
    final imagem = Uint8List.fromList(_imagemPngPlaceholder);

    return <Publicacao>[
      Publicacao(
        tipo: PublicacaoTipo.anuncio,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Loja Parceira',
        nome: 'Betoneira 150L',
        descricao: 'Usada, revisada e funcionando. Retirada no local.',
        preco: 950.0,
        criadoEm: now.subtract(const Duration(days: 2)),
        imagens: [imagem, imagem],
      ),
      Publicacao(
        tipo: PublicacaoTipo.anuncio,
        criadoPorId: _seedUserId,
        criadoPorNome: 'João da Obra',
        nome: 'Furadeira de impacto 650W',
        descricao: 'Acompanha maleta e brocas. Pouco uso.',
        preco: 220.0,
        criadoEm: now.subtract(const Duration(days: 4)),
        imagens: [imagem],
      ),
      Publicacao(
        tipo: PublicacaoTipo.anuncio,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Maria Materiais',
        nome: 'Areia lavada (m³)',
        descricao: 'Entrega no bairro. Preço por metro cúbico.',
        preco: 180.0,
        criadoEm: now.subtract(const Duration(days: 6)),
        imagens: [imagem],
      ),
      Publicacao(
        tipo: PublicacaoTipo.solicitacao,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Carlos',
        nome: 'Pedreiro para reboco',
        descricao:
            'Procuro pedreiro para rebocar 2 cômodos. Preferência por indicação.',
        preco: 1200.0,
        criadoEm: now.subtract(const Duration(days: 1)),
      ),
      Publicacao(
        tipo: PublicacaoTipo.solicitacao,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Ana',
        nome: 'Alugar andaime',
        descricao: 'Preciso de andaime por 7 dias para pintura externa.',
        preco: 350.0,
        criadoEm: now.subtract(const Duration(days: 3)),
      ),
      Publicacao(
        tipo: PublicacaoTipo.solicitacao,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Rafael',
        nome: 'Tijolo cerâmico',
        descricao: 'Busco 800 unidades. Pode ser retirada ou entrega.',
        preco: 900.0,
        criadoEm: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  Future<Uint8List> _criarImagemFicticia({
    required Color background,
    required Color accent,
  }) async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return Uint8List.fromList(_imagemPngPlaceholder);
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = ui.Size(96, 96);

    final bgPaint = Paint()..color = background;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(16),
      ),
      bgPaint,
    );

    final accentPaint = Paint()..color = accent.withAlpha(180);
    canvas.drawCircle(const Offset(48, 48), 26, accentPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) {
      throw StateError('Falha ao gerar imagem fictícia.');
    }
    return bytes.buffer.asUint8List();
  }

  Future<List<Publicacao>> _gerarPublicacoesFicticias(DateTime now) async {
    final imagem1 = await _criarImagemFicticia(
      background: Colors.deepOrange,
      accent: Colors.white,
    );
    final imagem2 = await _criarImagemFicticia(
      background: Colors.blue,
      accent: Colors.white,
    );
    final imagem3 = await _criarImagemFicticia(
      background: Colors.green,
      accent: Colors.white,
    );
    final imagem4 = await _criarImagemFicticia(
      background: Colors.deepPurple,
      accent: Colors.white,
    );

    return <Publicacao>[
      Publicacao(
        tipo: PublicacaoTipo.anuncio,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Loja Parceira',
        nome: 'Betoneira 150L',
        descricao: 'Usada, revisada e funcionando. Retirada no local.',
        preco: 950.0,
        criadoEm: now.subtract(const Duration(days: 2)),
        imagens: [imagem1, imagem4],
      ),
      Publicacao(
        tipo: PublicacaoTipo.anuncio,
        criadoPorId: _seedUserId,
        criadoPorNome: 'João da Obra',
        nome: 'Furadeira de impacto 650W',
        descricao: 'Acompanha maleta e brocas. Pouco uso.',
        preco: 220.0,
        criadoEm: now.subtract(const Duration(days: 4)),
        imagens: [imagem2],
      ),
      Publicacao(
        tipo: PublicacaoTipo.anuncio,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Maria Materiais',
        nome: 'Areia lavada (m³)',
        descricao: 'Entrega no bairro. Preço por metro cúbico.',
        preco: 180.0,
        criadoEm: now.subtract(const Duration(days: 6)),
        imagens: [imagem3],
      ),
      Publicacao(
        tipo: PublicacaoTipo.solicitacao,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Carlos',
        nome: 'Pedreiro para reboco',
        descricao:
            'Procuro pedreiro para rebocar 2 cômodos. Preferência por indicação.',
        preco: 1200.0,
        criadoEm: now.subtract(const Duration(days: 1)),
      ),
      Publicacao(
        tipo: PublicacaoTipo.solicitacao,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Ana',
        nome: 'Alugar andaime',
        descricao: 'Preciso de andaime por 7 dias para pintura externa.',
        preco: 350.0,
        criadoEm: now.subtract(const Duration(days: 3)),
      ),
      Publicacao(
        tipo: PublicacaoTipo.solicitacao,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Rafael',
        nome: 'Tijolo cerâmico',
        descricao: 'Busco 800 unidades. Pode ser retirada ou entrega.',
        preco: 900.0,
        criadoEm: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  Future<void> _inserirPublicacoesFicticias() async {
    final now = DateTime.now();
    final publicacoes = await _gerarPublicacoesFicticias(now);

    for (final p in publicacoes) {
      await LocalDatabase.instance.inserirPublicacao(p);
    }
  }

  Future<void> _inserirAnunciosFicticiosComImagens() async {
    final now = DateTime.now();
    final imagem1 = await _criarImagemFicticia(
      background: Colors.deepOrange,
      accent: Colors.white,
    );
    final imagem2 = await _criarImagemFicticia(
      background: Colors.blue,
      accent: Colors.white,
    );
    final imagem3 = await _criarImagemFicticia(
      background: Colors.green,
      accent: Colors.white,
    );
    final imagem4 = await _criarImagemFicticia(
      background: Colors.deepPurple,
      accent: Colors.white,
    );

    final anuncios = <Publicacao>[
      Publicacao(
        tipo: PublicacaoTipo.anuncio,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Loja Parceira',
        nome: 'Betoneira 150L (com fotos)',
        descricao: 'Usada, revisada e funcionando. Retirada no local.',
        preco: 950.0,
        criadoEm: now.subtract(const Duration(days: 2)),
        imagens: [imagem1, imagem4],
      ),
      Publicacao(
        tipo: PublicacaoTipo.anuncio,
        criadoPorId: _seedUserId,
        criadoPorNome: 'João da Obra',
        nome: 'Furadeira 650W (com fotos)',
        descricao: 'Acompanha maleta e brocas. Pouco uso.',
        preco: 220.0,
        criadoEm: now.subtract(const Duration(days: 4)),
        imagens: [imagem2],
      ),
      Publicacao(
        tipo: PublicacaoTipo.anuncio,
        criadoPorId: _seedUserId,
        criadoPorNome: 'Maria Materiais',
        nome: 'Areia lavada (m³) (com fotos)',
        descricao: 'Entrega no bairro. Preço por metro cúbico.',
        preco: 180.0,
        criadoEm: now.subtract(const Duration(days: 6)),
        imagens: [imagem3],
      ),
    ];

    for (final a in anuncios) {
      await LocalDatabase.instance.inserirPublicacao(a);
    }
  }

  void _adicionarPublicacao(Publicacao publicacao) {
    setState(() => _publicacoes.insert(0, publicacao));
    _salvarPublicacao(publicacao);

    final destinoIndex =
        publicacao.tipo == PublicacaoTipo.solicitacao ? 0 : 1;
    setState(() => _currentIndex = destinoIndex);
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      SolicitacoesPage(
        publicacoes: _publicacoes
            .where((p) => p.tipo == PublicacaoTipo.solicitacao)
            .toList(growable: false),
      ),
      AnunciosPage(
        publicacoes: _publicacoes
            .where((p) => p.tipo == PublicacaoTipo.anuncio)
            .toList(growable: false),
      ),
      CriarPage(
        onCriar: _adicionarPublicacao,
        criadoPorId: _userId,
        criadoPorNome: _nomePerfil,
      ),
      PerfilPage(
        nome: _nomePerfil,
        foto: _fotoPerfil,
        meusAnuncios: _publicacoes
            .where(
              (p) => p.tipo == PublicacaoTipo.anuncio && p.criadoPorId == _userId,
            )
            .toList(growable: false),
        onNomeAlterado: (nome) => setState(() => _nomePerfil = nome),
        onFotoAlterada: (foto) => setState(() => _fotoPerfil = foto),
      ),
    ];

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_titles[_currentIndex]),
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
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
