import 'package:flutter/material.dart';

class CriarInformacoesFields extends StatelessWidget {
  const CriarInformacoesFields({
    super.key,
    required this.nomeController,
    required this.descricaoController,
    required this.precoController,
    required this.labelNome,
    required this.labelDescricao,
    required this.labelPreco,
    required this.validarCampoObrigatorio,
    required this.validarPreco,
  });

  final TextEditingController nomeController;
  final TextEditingController descricaoController;
  final TextEditingController precoController;
  final String labelNome;
  final String labelDescricao;
  final String labelPreco;
  final FormFieldValidator<String> validarCampoObrigatorio;
  final FormFieldValidator<String> validarPreco;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nomeController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: labelNome,
            prefixIcon: const Icon(Icons.inventory_2_outlined),
            border: const OutlineInputBorder(),
          ),
          validator: validarCampoObrigatorio,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: descricaoController,
          minLines: 4,
          maxLines: 7,
          decoration: InputDecoration(
            labelText: labelDescricao,
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.notes_outlined),
            border: const OutlineInputBorder(),
          ),
          validator: validarCampoObrigatorio,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: precoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: labelPreco,
            hintText: 'Ex: 120,00',
            prefixIcon: const Icon(Icons.payments_outlined),
            border: const OutlineInputBorder(),
          ),
          validator: validarPreco,
        ),
      ],
    );
  }
}
