import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local_database.dart';
import '../../utils/formatters.dart';

class CarteiraPage extends StatefulWidget {
  const CarteiraPage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<CarteiraPage> createState() => _CarteiraPageState();
}

class _CarteiraPageState extends State<CarteiraPage> {
  double _saldo = 180.75;
  bool _atualizandoSaldo = false;

  String? _pinRecebimento;
  bool _carregandoPin = true;

  late final List<_Compra> _compras = [
    _Compra(
      nome: 'Kit de ferramentas',
      valor: 59.90,
      data: DateTime(2026, 4, 4),
    ),
    _Compra(
      nome: 'Luva de proteção',
      valor: 18.50,
      data: DateTime(2026, 4, 12),
    ),
    _Compra(
      nome: 'Botina de segurança',
      valor: 129.90,
      data: DateTime(2026, 4, 20),
    ),
  ];

  String get _pinPrefsKey => 'pin_recebimento:${widget.userId}';

  @override
  void initState() {
    super.initState();
    _carregarPinRecebimento();
  }

  Future<void> _carregarPinRecebimento() async {
    setState(() => _carregandoPin = true);
    String? pin;
    try {
      try {
        final prefs = await SharedPreferences.getInstance();
        pin = prefs.getString(_pinPrefsKey);
        if ((pin ?? '').trim().isEmpty) pin = null;
      } catch (_) {
        pin = null;
      }

      if (!kIsWeb && pin == null) {
        try {
          pin = await LocalDatabase.instance
              .obterPinRecebimento(userId: widget.userId);
          if ((pin ?? '').trim().isEmpty) pin = null;
        } catch (_) {
          pin = null;
        }

        if (pin != null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_pinPrefsKey, pin);
          } catch (_) {}
        }
      }
    } catch (_) {
      pin = null;
    }

    if (!mounted) return;
    setState(() {
      _pinRecebimento = pin;
      _carregandoPin = false;
    });
  }

  Future<void> _abrirSaque() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      final valor = await showDialog<double>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Sacar'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  hintText: 'Ex: 50,00',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final parsed = parseMoneyInput(value ?? '');
                  if (parsed == null) return 'Informe um valor.';
                  if (parsed <= 0) return 'Informe um valor maior que zero.';
                  if (parsed > _saldo) return 'Saldo insuficiente.';
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  final isValid = formKey.currentState?.validate() ?? false;
                  if (!isValid) return;
                  final parsed = parseMoneyInput(controller.text);
                  Navigator.of(dialogContext).pop(parsed);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final isValid = formKey.currentState?.validate() ?? false;
                  if (!isValid) return;
                  final parsed = parseMoneyInput(controller.text);
                  Navigator.of(dialogContext).pop(parsed);
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );

      if (!mounted || valor == null) return;
      setState(() => _saldo -= valor);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saque de ${formatMoneyBRL(valor)} solicitado.')),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _atualizarSaldo() async {
    if (_atualizandoSaldo) return;
    setState(() => _atualizandoSaldo = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _atualizandoSaldo = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saldo atualizado: ${formatMoneyBRL(_saldo)}')),
    );
  }

  Future<bool> _pedirPinEValidar() async {
    final pinCadastrado = _pinRecebimento;
    if (_carregandoPin) return false;
    if (pinCadastrado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você ainda não gerou seu PIN de recebimento. Vá em Perfil > Gerar PIN.',
          ),
        ),
      );
      return false;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmarRecebimentoDialog(pinCadastrado: pinCadastrado),
    );
    return ok ?? false;
  }

  Future<void> _confirmarRecebimento(int index) async {
    final messenger = ScaffoldMessenger.of(context);
    final compra = _compras[index];
    if (compra.recebido) return;

    final ok = await _pedirPinEValidar();
    if (!mounted || !ok) return;

    setState(() {
      _compras[index] = compra.copyWith(
        recebido: true,
        recebidoEm: DateTime.now(),
      );
    });

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Recebimento de "${compra.nome}" confirmado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo disponível',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  formatMoneyBRL(_saldo),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _saldo <= 0 ? null : _abrirSaque,
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Sacar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _atualizandoSaldo ? null : _atualizarSaldo,
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        _atualizandoSaldo ? 'Atualizando...' : 'Atualizar saldo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Meus itens comprados',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (_compras.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Você ainda não comprou nenhum item.'),
            ),
          )
        else
          ..._compras.asMap().entries.map((entry) {
            final index = entry.key;
            final c = entry.value;
            final recebidoEm = c.recebidoEm;
            return Card(
              child: Column(
                children: [
                  ListTile(
                    isThreeLine: c.recebido && recebidoEm != null,
                    leading: Icon(
                      c.recebido
                          ? Icons.check_circle_outline
                          : Icons.shopping_bag_outlined,
                    ),
                    title: Text(c.nome),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatDateBR(c.data)),
                        if (c.recebido && recebidoEm != null)
                          Text('Recebido em ${formatDateBR(recebidoEm)}'),
                      ],
                    ),
                    trailing: Text(formatMoneyBRL(c.valor)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: c.recebido
                          ? FilledButton.tonalIcon(
                              onPressed: null,
                              icon: const Icon(Icons.verified_outlined),
                              label: const Text('Recebido'),
                            )
                          : FilledButton.icon(
                              onPressed: _carregandoPin
                                  ? null
                                  : () => _confirmarRecebimento(index),
                              icon: const Icon(Icons.verified_outlined),
                              label: const Text('Confirmar recebimento'),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _Compra {
  _Compra({
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

  _Compra copyWith({
    bool? recebido,
    DateTime? recebidoEm,
  }) {
    return _Compra(
      nome: nome,
      valor: valor,
      data: data,
      recebido: recebido ?? this.recebido,
      recebidoEm: recebidoEm ?? this.recebidoEm,
    );
  }
}

class _ConfirmarRecebimentoDialog extends StatefulWidget {
  const _ConfirmarRecebimentoDialog({
    required this.pinCadastrado,
  });

  final String pinCadastrado;

  @override
  State<_ConfirmarRecebimentoDialog> createState() =>
      _ConfirmarRecebimentoDialogState();
}

class _ConfirmarRecebimentoDialogState
    extends State<_ConfirmarRecebimentoDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _pinVisivel = false;
  String? _erroPin;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final digitado = _controller.text.trim();
    if (digitado != widget.pinCadastrado) {
      if (!mounted) return;
      setState(() => _erroPin = 'PIN incorreto.');
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar recebimento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                obscureText: !_pinVisivel,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (_) {
                  if (_erroPin == null) return;
                  setState(() => _erroPin = null);
                },
                decoration: InputDecoration(
                  labelText: 'PIN (6 dígitos)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _pinVisivel = !_pinVisivel),
                    icon: Icon(
                      _pinVisivel
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    tooltip: _pinVisivel ? 'Ocultar' : 'Mostrar',
                  ),
                ),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Informe o PIN.';
                  if (v.length != 6) return 'O PIN deve ter 6 dígitos.';
                  return null;
                },
                onFieldSubmitted: (_) => _confirmar(),
              ),
              if (_erroPin != null) ...[
                const SizedBox(height: 8),
                Text(
                  _erroPin!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
