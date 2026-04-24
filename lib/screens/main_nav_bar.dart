import 'package:flutter/material.dart';

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
  int _currentIndex = 1;

  final List<Publicacao> _publicacoes = [];

  static const List<String> _titles = [
    'Solicitações',
    'Home Page',
    'Criar',
    'Perfil',
  ];

  void _adicionarPublicacao(Publicacao publicacao) {
    setState(() => _publicacoes.insert(0, publicacao));

    final destinoIndex =
        publicacao.tipo == PublicacaoTipo.solicitacao ? 0 : 1;
    setState(() => _currentIndex = destinoIndex);
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
      CriarPage(onCriar: _adicionarPublicacao),
      const PerfilPage(),
    ];

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

