import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local_database.dart';
import '../../utils/formatters.dart';
import '../../models/compra.dart';
import '../../widgets/compra_card.dart';
import '../../widgets/confirmar_recebimento_dialog.dart';

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

  late final List<Compra> _compras = [
    Compra(
      nome: 'Kit de ferramentas',
      valor: 59.90,
      data: DateTime(2026, 4, 4),
    ),
    Compra(
      nome: 'Luva de proteção',
      valor: 18.50,
      data: DateTime(2026, 4, 12),
    ),
    Compra(
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
      builder: (_) =>
          ConfirmarRecebimentoDialog(pinCadastrado: pinCadastrado),
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
            return CompraCard(
              compra: c,
              confirmEnabled: !_carregandoPin,
              onConfirmarRecebimento: () => _confirmarRecebimento(index),
            );
          }),
      ],
    );
  }
}
