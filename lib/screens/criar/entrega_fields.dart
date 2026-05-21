import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/publicacao.dart';
import '../../utils/formatters.dart';

class EntregaFields extends StatelessWidget {
  const EntregaFields({
    super.key,
    required this.logistica,
    required this.cepController,
    required this.valorPorKmController,
    required this.aceitaPropostas,
    required this.onLogisticaChanged,
    required this.onAceitaPropostasChanged,
  });

  final AnuncioLogistica logistica;
  final TextEditingController cepController;
  final TextEditingController valorPorKmController;
  final bool aceitaPropostas;
  final ValueChanged<AnuncioLogistica> onLogisticaChanged;
  final ValueChanged<bool> onAceitaPropostasChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Entrega', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<AnuncioLogistica>(
          key: ValueKey(logistica),
          initialValue: logistica,
          decoration: const InputDecoration(
            labelText: 'Como funciona?',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: AnuncioLogistica.retiradaLocal,
              child: Text('Retirada no local'),
            ),
            DropdownMenuItem(
              value: AnuncioLogistica.entrega,
              child: Text('Faz entrega'),
            ),
          ],
          onChanged: (value) {
            if (value != null) onLogisticaChanged(value);
          },
        ),
        if (logistica == AnuncioLogistica.entrega) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: cepController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: const InputDecoration(
              labelText: 'Seu CEP (origem da entrega)',
              hintText: 'Ex: 12345678',
              border: OutlineInputBorder(),
            ),
            validator: (_) {
              final cep = cepController.text.trim();
              if (cep.isEmpty) return 'Informe seu CEP.';
              if (cep.length != 8) return 'CEP deve ter 8 dígitos.';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: valorPorKmController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quanto cobra por km (R\$)',
              hintText: 'Ex: 2,50',
              border: OutlineInputBorder(),
            ),
            validator: (_) {
              final parsed = parseMoneyInput(valorPorKmController.text);
              if (parsed == null) return 'Informe o valor por km.';
              if (parsed <= 0) return 'O valor por km deve ser > 0.';
              return null;
            },
          ),
        ],
        const SizedBox(height: 12),
        SwitchListTile(
          value: aceitaPropostas,
          onChanged: onAceitaPropostasChanged,
          title: const Text('Aceita propostas de valor diferentes'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
