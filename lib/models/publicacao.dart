import 'dart:convert';
import 'dart:typed_data';

enum PublicacaoTipo { anuncio, solicitacao }

enum AnuncioLogistica { retiradaLocal, entrega }

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
    this.anuncioLogistica,
    this.entregaCep,
    this.entregaValorPorKm,
    this.aceitaPropostas = false,
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
  final AnuncioLogistica? anuncioLogistica;
  final String? entregaCep;
  final double? entregaValorPorKm;
  final bool aceitaPropostas;

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
      anuncioLogistica: anuncioLogistica,
      entregaCep: entregaCep,
      entregaValorPorKm: entregaValorPorKm,
      aceitaPropostas: aceitaPropostas,
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
      'anuncio_logistica': anuncioLogistica?.name,
      'entrega_cep': entregaCep,
      'entrega_valor_por_km': entregaValorPorKm,
      'aceita_propostas': aceitaPropostas ? 1 : 0,
    };
  }

  factory Publicacao.fromDbMap(Map<String, Object?> map) {
    final imagensJson = map['imagens_json'] as String? ?? '[]';
    final imagensBase64 = (jsonDecode(imagensJson) as List<dynamic>)
        .whereType<String>()
        .toList(growable: false);

    final tipo = PublicacaoTipo.values.byName(map['tipo'] as String);

    AnuncioLogistica? anuncioLogistica;
    if (tipo == PublicacaoTipo.anuncio) {
      final raw = map['anuncio_logistica'] as String?;
      if (raw == null || raw.isEmpty) {
        anuncioLogistica = AnuncioLogistica.retiradaLocal;
      } else {
        try {
          anuncioLogistica = AnuncioLogistica.values.byName(raw);
        } catch (_) {
          anuncioLogistica = AnuncioLogistica.retiradaLocal;
        }
      }
    }

    final aceitaRaw = map['aceita_propostas'];
    final aceitaPropostas = switch (aceitaRaw) {
      int v => v == 1,
      num v => v.toInt() == 1,
      bool v => v,
      _ => false,
    };

    String? entregaCep;
    double? entregaValorPorKm;
    if (tipo == PublicacaoTipo.anuncio &&
        anuncioLogistica == AnuncioLogistica.entrega) {
      entregaCep = map['entrega_cep'] as String?;
      final rawKm = map['entrega_valor_por_km'];
      if (rawKm is num) entregaValorPorKm = rawKm.toDouble();
    }

    return Publicacao(
      id: map['id'] as int?,
      tipo: tipo,
      criadoPorId: map['criado_por_id'] as String,
      criadoPorNome: map['criado_por_nome'] as String,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
      preco: (map['preco'] as num).toDouble(),
      criadoEm: DateTime.parse(map['criado_em'] as String),
      imagens: imagensBase64.map((img) => base64Decode(img)).toList(),
      anuncioLogistica: anuncioLogistica,
      entregaCep: entregaCep,
      entregaValorPorKm: entregaValorPorKm,
      aceitaPropostas: tipo == PublicacaoTipo.anuncio ? aceitaPropostas : false,
    );
  }
}
