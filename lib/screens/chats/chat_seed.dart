import 'chat_models.dart';

const conversasFicticias = <ChatSummary>[
  ChatSummary(
    id: 'areia',
    nome: 'João - Areia',
    ultimaMensagem: 'Anotado. Chego entre 9h e 10h.',
    hora: '08:50',
    naoLidas: 2,
  ),
  ChatSummary(
    id: 'tijolo',
    nome: 'Maria - Tijolos',
    ultimaMensagem: 'Consigo fazer por R\$ 1,85 a unidade.',
    hora: 'Ontem',
    naoLidas: 0,
  ),
  ChatSummary(
    id: 'cimento',
    nome: 'Depósito Central',
    ultimaMensagem: 'Temos pronta entrega. Quer NF?',
    hora: 'Ontem',
    naoLidas: 4,
  ),
  ChatSummary(
    id: 'frete',
    nome: 'Carlos - Frete',
    ultimaMensagem: 'Me passa o endereço certinho que eu calculo.',
    hora: 'Seg',
    naoLidas: 0,
  ),
  ChatSummary(
    id: 'pintura',
    nome: 'Ana - Pinturas',
    ultimaMensagem: 'Qual metragem aproximada?',
    hora: 'Dom',
    naoLidas: 1,
  ),
];

List<ChatMessage> mensagensFicticias(String chatId) {
  if (chatId == 'tijolo') {
    return <ChatMessage>[
      const ChatMessage(
        texto: 'Oi! Você ainda tem tijolos baianinho?',
        enviadaPorMim: true,
        hora: '16:10',
      ),
      const ChatMessage(
        texto: 'Tenho sim. Quantos você precisa?',
        enviadaPorMim: false,
        hora: '16:11',
      ),
      const ChatMessage(
        texto: 'Queria 1.500 unidades.',
        enviadaPorMim: true,
        hora: '16:11',
      ),
      const ChatMessage(
        texto: 'Consigo fazer por R\$ 1,85 a unidade.',
        enviadaPorMim: false,
        hora: '16:12',
      ),
    ];
  }

  if (chatId == 'cimento') {
    return <ChatMessage>[
      const ChatMessage(
        texto: 'Bom dia! Tem cimento CP II 50kg?',
        enviadaPorMim: true,
        hora: '09:02',
      ),
      const ChatMessage(
        texto: 'Tem sim. Quantos sacos?',
        enviadaPorMim: false,
        hora: '09:03',
      ),
      const ChatMessage(
        texto: 'Uns 30 sacos. Entrega hoje?',
        enviadaPorMim: true,
        hora: '09:03',
      ),
      const ChatMessage(
        texto: 'Temos pronta entrega. Quer NF?',
        enviadaPorMim: false,
        hora: '09:04',
      ),
    ];
  }

  if (chatId == 'frete') {
    return <ChatMessage>[
      const ChatMessage(
        texto: 'Preciso de frete pra trazer brita. Você faz?',
        enviadaPorMim: true,
        hora: '11:22',
      ),
      const ChatMessage(
        texto: 'Faço sim. Me passa o endereço certinho que eu calculo.',
        enviadaPorMim: false,
        hora: '11:23',
      ),
    ];
  }

  if (chatId == 'pintura') {
    return <ChatMessage>[
      const ChatMessage(
        texto: 'Oi Ana! Você faz pintura interna?',
        enviadaPorMim: true,
        hora: '19:30',
      ),
      const ChatMessage(
        texto: 'Faço sim. Qual metragem aproximada?',
        enviadaPorMim: false,
        hora: '19:31',
      ),
    ];
  }

  return <ChatMessage>[
    const ChatMessage(
      texto: 'Oi! Vi seu anúncio de areia.',
      enviadaPorMim: true,
      hora: '08:41',
    ),
    const ChatMessage(
      texto: 'Oi! Tenho sim. Quantos m³ você precisa?',
      enviadaPorMim: false,
      hora: '08:42',
    ),
    const ChatMessage(
      texto: 'Preciso de 4m³. Consegue entregar?',
      enviadaPorMim: true,
      hora: '08:43',
    ),
    const ChatMessage(
      texto: 'Consigo. Qual o CEP para eu calcular?',
      enviadaPorMim: false,
      hora: '08:44',
    ),
    const ChatMessage(
      texto: '08750-000',
      enviadaPorMim: true,
      hora: '08:45',
    ),
    const ChatMessage(
      texto: 'Fica R\$ 35,00/km + o valor do material.',
      enviadaPorMim: false,
      hora: '08:46',
    ),
    const ChatMessage(
      texto: 'Fechado. Pode ser amanhã de manhã?',
      enviadaPorMim: true,
      hora: '08:47',
    ),
    const ChatMessage(
      texto: 'Pode sim. Me manda o endereço completo, por favor.',
      enviadaPorMim: false,
      hora: '08:48',
    ),
    const ChatMessage(
      texto: 'Rua das Flores, 123 - Centro. Referência: portão azul.',
      enviadaPorMim: true,
      hora: '08:49',
    ),
    const ChatMessage(
      texto: 'Anotado. Chego entre 9h e 10h.',
      enviadaPorMim: false,
      hora: '08:50',
    ),
  ];
}
