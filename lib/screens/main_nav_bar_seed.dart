import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/local_database.dart';
import '../models/publicacao.dart';

const String seedUserId = 'seed_user';
const List<int> imagemPngPlaceholder = <int>[
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

List<Publicacao> gerarPublicacoesFicticiasInstantanea(DateTime now) {
  final imagem = Uint8List.fromList(imagemPngPlaceholder);

  return <Publicacao>[
    Publicacao(
      tipo: PublicacaoTipo.anuncio,
      criadoPorId: seedUserId,
      criadoPorNome: 'Loja Parceira',
      nome: 'Betoneira 150L',
      descricao: 'Usada, revisada e funcionando. Retirada no local.',
      preco: 950.0,
      criadoEm: now.subtract(const Duration(days: 2)),
      imagens: [imagem, imagem],
    ),
    Publicacao(
      tipo: PublicacaoTipo.anuncio,
      criadoPorId: seedUserId,
      criadoPorNome: 'João da Obra',
      nome: 'Furadeira de impacto 650W',
      descricao: 'Acompanha maleta e brocas. Pouco uso.',
      preco: 220.0,
      criadoEm: now.subtract(const Duration(days: 4)),
      imagens: [imagem],
    ),
    Publicacao(
      tipo: PublicacaoTipo.anuncio,
      criadoPorId: seedUserId,
      criadoPorNome: 'Maria Materiais',
      nome: 'Areia lavada (m³)',
      descricao: 'Entrega no bairro. Preço por metro cúbico.',
      preco: 180.0,
      criadoEm: now.subtract(const Duration(days: 6)),
      imagens: [imagem],
    ),
    Publicacao(
      tipo: PublicacaoTipo.solicitacao,
      criadoPorId: seedUserId,
      criadoPorNome: 'Carlos',
      nome: 'Pedreiro para reboco',
      descricao:
          'Procuro pedreiro para rebocar 2 cômodos. Preferência por indicação.',
      preco: 1200.0,
      criadoEm: now.subtract(const Duration(days: 1)),
    ),
    Publicacao(
      tipo: PublicacaoTipo.solicitacao,
      criadoPorId: seedUserId,
      criadoPorNome: 'Ana',
      nome: 'Alugar andaime',
      descricao: 'Preciso de andaime por 7 dias para pintura externa.',
      preco: 350.0,
      criadoEm: now.subtract(const Duration(days: 3)),
    ),
    Publicacao(
      tipo: PublicacaoTipo.solicitacao,
      criadoPorId: seedUserId,
      criadoPorNome: 'Rafael',
      nome: 'Tijolo cerâmico',
      descricao: 'Busco 800 unidades. Pode ser retirada ou entrega.',
      preco: 900.0,
      criadoEm: now.subtract(const Duration(days: 5)),
    ),
  ];
}

Future<Uint8List> criarImagemFicticia({
  required Color background,
  required Color accent,
}) async {
  if (const bool.fromEnvironment('FLUTTER_TEST')) {
    return Uint8List.fromList(imagemPngPlaceholder);
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

Future<List<Uint8List>> gerarImagensFicticiasParaSeed() async {
  return [
    await criarImagemFicticia(
      background: Colors.deepOrange,
      accent: Colors.white,
    ),
    await criarImagemFicticia(
      background: Colors.blue,
      accent: Colors.white,
    ),
    await criarImagemFicticia(
      background: Colors.green,
      accent: Colors.white,
    ),
    await criarImagemFicticia(
      background: Colors.deepPurple,
      accent: Colors.white,
    ),
  ];
}

Future<List<Publicacao>> gerarPublicacoesFicticias(DateTime now) async {
  final imagens = await gerarImagensFicticiasParaSeed();

  return <Publicacao>[
    Publicacao(
      tipo: PublicacaoTipo.anuncio,
      criadoPorId: seedUserId,
      criadoPorNome: 'Loja Parceira',
      nome: 'Betoneira 150L',
      descricao: 'Usada, revisada e funcionando. Retirada no local.',
      preco: 950.0,
      criadoEm: now.subtract(const Duration(days: 2)),
      imagens: [imagens[0], imagens[3]],
    ),
    Publicacao(
      tipo: PublicacaoTipo.anuncio,
      criadoPorId: seedUserId,
      criadoPorNome: 'João da Obra',
      nome: 'Furadeira de impacto 650W',
      descricao: 'Acompanha maleta e brocas. Pouco uso.',
      preco: 220.0,
      criadoEm: now.subtract(const Duration(days: 4)),
      imagens: [imagens[1]],
    ),
    Publicacao(
      tipo: PublicacaoTipo.anuncio,
      criadoPorId: seedUserId,
      criadoPorNome: 'Maria Materiais',
      nome: 'Areia lavada (m³)',
      descricao: 'Entrega no bairro. Preço por metro cúbico.',
      preco: 180.0,
      criadoEm: now.subtract(const Duration(days: 6)),
      imagens: [imagens[2]],
    ),
    Publicacao(
      tipo: PublicacaoTipo.solicitacao,
      criadoPorId: seedUserId,
      criadoPorNome: 'Carlos',
      nome: 'Pedreiro para reboco',
      descricao:
          'Procuro pedreiro para rebocar 2 cômodos. Preferência por indicação.',
      preco: 1200.0,
      criadoEm: now.subtract(const Duration(days: 1)),
    ),
    Publicacao(
      tipo: PublicacaoTipo.solicitacao,
      criadoPorId: seedUserId,
      criadoPorNome: 'Ana',
      nome: 'Alugar andaime',
      descricao: 'Preciso de andaime por 7 dias para pintura externa.',
      preco: 350.0,
      criadoEm: now.subtract(const Duration(days: 3)),
    ),
    Publicacao(
      tipo: PublicacaoTipo.solicitacao,
      criadoPorId: seedUserId,
      criadoPorNome: 'Rafael',
      nome: 'Tijolo cerâmico',
      descricao: 'Busco 800 unidades. Pode ser retirada ou entrega.',
      preco: 900.0,
      criadoEm: now.subtract(const Duration(days: 5)),
    ),
  ];
}

Future<void> inserirPublicacoesFicticias(LocalDatabase database) async {
  final now = DateTime.now();
  final publicacoes = await gerarPublicacoesFicticias(now);

  for (final p in publicacoes) {
    await database.inserirPublicacao(p);
  }
}

Future<void> inserirAnunciosFicticiosComImagens(LocalDatabase database) async {
  final now = DateTime.now();
  final imagens = await gerarImagensFicticiasParaSeed();

  final anuncios = <Publicacao>[
    Publicacao(
      tipo: PublicacaoTipo.anuncio,
      criadoPorId: seedUserId,
      criadoPorNome: 'Loja Parceira',
      nome: 'Betoneira 150L (com fotos)',
      descricao: 'Usada, revisada e funcionando. Retirada no local.',
      preco: 950.0,
      criadoEm: now.subtract(const Duration(days: 2)),
      imagens: [imagens[0], imagens[3]],
    ),
    Publicacao(
      tipo: PublicacaoTipo.anuncio,
      criadoPorId: seedUserId,
      criadoPorNome: 'João da Obra',
      nome: 'Furadeira 650W (com fotos)',
      descricao: 'Acompanha maleta e brocas. Pouco uso.',
      preco: 220.0,
      criadoEm: now.subtract(const Duration(days: 4)),
      imagens: [imagens[1]],
    ),
    Publicacao(
      tipo: PublicacaoTipo.anuncio,
      criadoPorId: seedUserId,
      criadoPorNome: 'Maria Materiais',
      nome: 'Areia lavada (m³) (com fotos)',
      descricao: 'Entrega no bairro. Preço por metro cúbico.',
      preco: 180.0,
      criadoEm: now.subtract(const Duration(days: 6)),
      imagens: [imagens[2]],
    ),
  ];

  for (final a in anuncios) {
    await database.inserirPublicacao(a);
  }
}
