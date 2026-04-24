enum PublicacaoTipo { anuncio, solicitacao }

class Publicacao {
  Publicacao({
    required this.tipo,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.criadoEm,
  });

  final PublicacaoTipo tipo;
  final String nome;
  final String descricao;
  final double preco;
  final DateTime criadoEm;
}

