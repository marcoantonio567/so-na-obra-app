import 'dart:typed_data';

enum PublicacaoTipo { anuncio, solicitacao }

class Publicacao {
  Publicacao({
    required this.tipo,
    required this.criadoPorId,
    required this.criadoPorNome,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.criadoEm,
    List<Uint8List>? imagens,
  }) : imagens = List.unmodifiable(imagens ?? const <Uint8List>[]);

  final PublicacaoTipo tipo;
  final String criadoPorId;
  final String criadoPorNome;
  final String nome;
  final String descricao;
  final double preco;
  final DateTime criadoEm;
  final List<Uint8List> imagens;
}
