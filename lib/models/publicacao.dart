import 'dart:convert';
import 'dart:typed_data';

enum PublicacaoTipo { anuncio, solicitacao }

class Publicacao {
  Publicacao({
    this.id,
    required this.tipo,
    required this.criadoPorId,
    required this.criadoPorNome,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.criadoEm,
    List<Uint8List>? imagens,
  }) : imagens = List.unmodifiable(imagens ?? const <Uint8List>[]);

  final int? id;
  final PublicacaoTipo tipo;
  final String criadoPorId;
  final String criadoPorNome;
  final String nome;
  final String descricao;
  final double preco;
  final DateTime criadoEm;
  final List<Uint8List> imagens;

  Publicacao copyWith({int? id}) {
    return Publicacao(
      id: id ?? this.id,
      tipo: tipo,
      criadoPorId: criadoPorId,
      criadoPorNome: criadoPorNome,
      nome: nome,
      descricao: descricao,
      preco: preco,
      criadoEm: criadoEm,
      imagens: imagens,
    );
  }

  Map<String, Object?> toDbMap() {
    return {
      'id': id,
      'tipo': tipo.name,
      'criado_por_id': criadoPorId,
      'criado_por_nome': criadoPorNome,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'criado_em': criadoEm.toIso8601String(),
      'imagens_json': jsonEncode(
        imagens.map((img) => base64Encode(img)).toList(growable: false),
      ),
    };
  }

  factory Publicacao.fromDbMap(Map<String, Object?> map) {
    final imagensJson = map['imagens_json'] as String? ?? '[]';
    final imagensBase64 = (jsonDecode(imagensJson) as List<dynamic>)
        .whereType<String>()
        .toList(growable: false);

    return Publicacao(
      id: map['id'] as int?,
      tipo: PublicacaoTipo.values.byName(map['tipo'] as String),
      criadoPorId: map['criado_por_id'] as String,
      criadoPorNome: map['criado_por_nome'] as String,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
      preco: (map['preco'] as num).toDouble(),
      criadoEm: DateTime.parse(map['criado_em'] as String),
      imagens: imagensBase64.map((img) => base64Decode(img)).toList(),
    );
  }
}
