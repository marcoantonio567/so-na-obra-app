import 'package:flutter/material.dart';

class PinRecebimentoCard extends StatelessWidget {
  const PinRecebimentoCard({
    super.key,
    required this.pin,
    required this.carregando,
    required this.visivel,
    required this.onCopiar,
    required this.onGerarOuRegenerar,
    required this.onAlternarVisibilidade,
  });

  final String? pin;
  final bool carregando;
  final bool visivel;
  final VoidCallback onCopiar;
  final VoidCallback onGerarOuRegenerar;
  final VoidCallback onAlternarVisibilidade;

  @override
  Widget build(BuildContext context) {
    final pinAtual = pin;
    final pinMascara = pinAtual == null ? '-' : '******';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PIN de recebimento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (pinAtual != null)
                  IconButton(
                    onPressed: onCopiar,
                    icon: const Icon(Icons.copy_outlined),
                    tooltip: 'Copiar',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      carregando
                          ? 'Carregando...'
                          : (pinAtual == null
                              ? 'Nenhum PIN gerado ainda.'
                              : (visivel ? pinAtual : pinMascara)),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (pinAtual != null && !carregando)
                    IconButton(
                      onPressed: onAlternarVisibilidade,
                      icon: Icon(
                        visivel
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      tooltip: visivel ? 'Ocultar' : 'Mostrar',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use este PIN para confirmar o recebimento da mercadoria.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: carregando ? null : onGerarOuRegenerar,
                  icon: Icon(pinAtual == null ? Icons.key : Icons.refresh),
                  label: Text(
                    pinAtual == null ? 'Gerar PIN' : 'Gerar novo PIN',
                  ),
                ),
                if (pinAtual != null)
                  OutlinedButton.icon(
                    onPressed: carregando ? null : onCopiar,
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copiar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
