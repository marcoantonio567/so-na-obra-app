class Compra {
  Compra({
    required this.nome,
    required this.valor,
    required this.data,
    this.recebido = false,
    this.recebidoEm,
  });

  final String nome;
  final double valor;
  final DateTime data;
  final bool recebido;
  final DateTime? recebidoEm;

  Compra copyWith({
    bool? recebido,
    DateTime? recebidoEm,
  }) {
    return Compra(
      nome: nome,
      valor: valor,
      data: data,
      recebido: recebido ?? this.recebido,
      recebidoEm: recebidoEm ?? this.recebidoEm,
    );
  }
}
