import 'package:flutter/material.dart';

import '../../utils/formatters.dart';

class CarteiraPage extends StatefulWidget {
  const CarteiraPage({super.key});

  @override
  State<CarteiraPage> createState() => _CarteiraPageState();
}

class _CarteiraPageState extends State<CarteiraPage> {
  double _saldo = 180.75;
  bool _atualizandoSaldo = false;

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
          ..._compras.map(
            (c) => Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: Text(c.nome),
                subtitle: Text(formatDateBR(c.data)),
                trailing: Text(formatMoneyBRL(c.valor)),
              ),
            ),
          ),
      ],
    );
  }
}

class _Compra {
  const _Compra({
    required this.nome,
    required this.valor,
    required this.data,
  });

  final String nome;
  final double valor;
  final DateTime data;
}
