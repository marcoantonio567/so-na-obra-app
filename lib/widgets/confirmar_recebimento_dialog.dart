import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmarRecebimentoDialog extends StatefulWidget {
  const ConfirmarRecebimentoDialog({
    super.key,
    required this.pinCadastrado,
  });

  final String pinCadastrado;

  @override
  State<ConfirmarRecebimentoDialog> createState() =>
      _ConfirmarRecebimentoDialogState();
}

class _ConfirmarRecebimentoDialogState
    extends State<ConfirmarRecebimentoDialog> {
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
