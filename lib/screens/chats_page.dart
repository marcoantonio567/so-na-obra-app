import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final conversas = <_ChatSummary>[
      const _ChatSummary(
        id: 'areia',
        nome: 'João - Areia',
        ultimaMensagem: 'Anotado. Chego entre 9h e 10h.',
        hora: '08:50',
        naoLidas: 2,
      ),
      const _ChatSummary(
        id: 'tijolo',
        nome: 'Maria - Tijolos',
        ultimaMensagem: 'Consigo fazer por R\$ 1,85 a unidade.',
        hora: 'Ontem',
        naoLidas: 0,
      ),
      const _ChatSummary(
        id: 'cimento',
        nome: 'Depósito Central',
        ultimaMensagem: 'Temos pronta entrega. Quer NF?',
        hora: 'Ontem',
        naoLidas: 4,
      ),
      const _ChatSummary(
        id: 'frete',
        nome: 'Carlos - Frete',
        ultimaMensagem: 'Me passa o endereço certinho que eu calculo.',
        hora: 'Seg',
        naoLidas: 0,
      ),
      const _ChatSummary(
        id: 'pintura',
        nome: 'Ana - Pinturas',
        ultimaMensagem: 'Qual metragem aproximada?',
        hora: 'Dom',
        naoLidas: 1,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: conversas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final c = conversas[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  c.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  c.ultimaMensagem,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      c.hora,
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 6),
                    if (c.naoLidas > 0)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            '${c.naoLidas}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _ChatThreadPage(chat: c),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChatSummary {
  const _ChatSummary({
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

class _ChatThreadPage extends StatefulWidget {
  const _ChatThreadPage({required this.chat});

  final _ChatSummary chat;

  @override
  State<_ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<_ChatThreadPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  late final List<_ChatMessage> _mensagens = _mensagensFicticias(widget.chat.id);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_ChatMessage> _mensagensFicticias(String chatId) {
    if (chatId == 'tijolo') {
      return <_ChatMessage>[
        _ChatMessage(
          texto: 'Oi! Você ainda tem tijolos baianinho?',
          enviadaPorMim: true,
          hora: '16:10',
        ),
        _ChatMessage(
          texto: 'Tenho sim. Quantos você precisa?',
          enviadaPorMim: false,
          hora: '16:11',
        ),
        _ChatMessage(
          texto: 'Queria 1.500 unidades.',
          enviadaPorMim: true,
          hora: '16:11',
        ),
        _ChatMessage(
          texto: 'Consigo fazer por R\$ 1,85 a unidade.',
          enviadaPorMim: false,
          hora: '16:12',
        ),
      ];
    }

    if (chatId == 'cimento') {
      return <_ChatMessage>[
        _ChatMessage(
          texto: 'Bom dia! Tem cimento CP II 50kg?',
          enviadaPorMim: true,
          hora: '09:02',
        ),
        _ChatMessage(
          texto: 'Tem sim. Quantos sacos?',
          enviadaPorMim: false,
          hora: '09:03',
        ),
        _ChatMessage(
          texto: 'Uns 30 sacos. Entrega hoje?',
          enviadaPorMim: true,
          hora: '09:03',
        ),
        _ChatMessage(
          texto: 'Temos pronta entrega. Quer NF?',
          enviadaPorMim: false,
          hora: '09:04',
        ),
      ];
    }

    if (chatId == 'frete') {
      return <_ChatMessage>[
        _ChatMessage(
          texto: 'Preciso de frete pra trazer brita. Você faz?',
          enviadaPorMim: true,
          hora: '11:22',
        ),
        _ChatMessage(
          texto: 'Faço sim. Me passa o endereço certinho que eu calculo.',
          enviadaPorMim: false,
          hora: '11:23',
        ),
      ];
    }

    if (chatId == 'pintura') {
      return <_ChatMessage>[
        _ChatMessage(
          texto: 'Oi Ana! Você faz pintura interna?',
          enviadaPorMim: true,
          hora: '19:30',
        ),
        _ChatMessage(
          texto: 'Faço sim. Qual metragem aproximada?',
          enviadaPorMim: false,
          hora: '19:31',
        ),
      ];
    }

    return <_ChatMessage>[
      _ChatMessage(
        texto: 'Oi! Vi seu anúncio de areia.',
        enviadaPorMim: true,
        hora: '08:41',
      ),
      _ChatMessage(
        texto: 'Oi! Tenho sim. Quantos m³ você precisa?',
        enviadaPorMim: false,
        hora: '08:42',
      ),
      _ChatMessage(
        texto: 'Preciso de 4m³. Consegue entregar?',
        enviadaPorMim: true,
        hora: '08:43',
      ),
      _ChatMessage(
        texto: 'Consigo. Qual o CEP para eu calcular?',
        enviadaPorMim: false,
        hora: '08:44',
      ),
      _ChatMessage(
        texto: '08750-000',
        enviadaPorMim: true,
        hora: '08:45',
      ),
      _ChatMessage(
        texto: 'Fica R\$ 35,00/km + o valor do material.',
        enviadaPorMim: false,
        hora: '08:46',
      ),
      _ChatMessage(
        texto: 'Fechado. Pode ser amanhã de manhã?',
        enviadaPorMim: true,
        hora: '08:47',
      ),
      _ChatMessage(
        texto: 'Pode sim. Me manda o endereço completo, por favor.',
        enviadaPorMim: false,
        hora: '08:48',
      ),
      _ChatMessage(
        texto: 'Rua das Flores, 123 - Centro. Referência: portão azul.',
        enviadaPorMim: true,
        hora: '08:49',
      ),
      _ChatMessage(
        texto: 'Anotado. Chego entre 9h e 10h.',
        enviadaPorMim: false,
        hora: '08:50',
      ),
    ];
  }

  void _enviar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensagens.add(
        _ChatMessage(
          texto: texto,
          enviadaPorMim: true,
          hora: _formatHora(DateTime.now()),
        ),
      );
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatHora(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.chat.nome)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _mensagens.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final m = _mensagens[index];
                  return _MensagemBubble(
                    mensagem: m,
                    theme: theme,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                      decoration: const InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _enviar,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.texto,
    required this.enviadaPorMim,
    required this.hora,
  });

  final String texto;
  final bool enviadaPorMim;
  final String hora;
}

class _MensagemBubble extends StatelessWidget {
  const _MensagemBubble({
    required this.mensagem,
    required this.theme,
  });

  final _ChatMessage mensagem;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isMe = mensagem.enviadaPorMim;
    final bg = isMe
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final fg = isMe
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  mensagem.texto,
                  style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                ),
                const SizedBox(height: 6),
                Text(
                  mensagem.hora,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fg.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
