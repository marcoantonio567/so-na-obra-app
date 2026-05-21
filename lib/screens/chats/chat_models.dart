class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.nome,
    required this.ultimaMensagem,
    required this.hora,
    required this.naoLidas,
  });

  final String id;
  final String nome;
  final String ultimaMensagem;
  final String hora;
  final int naoLidas;
}

class ChatMessage {
  const ChatMessage({
    required this.texto,
    required this.enviadaPorMim,
    required this.hora,
  });

  final String texto;
  final bool enviadaPorMim;
  final String hora;
}
