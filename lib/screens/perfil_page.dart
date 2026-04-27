import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/publicacao.dart';
import '../widgets/publicacao_card.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({
    super.key,
    required this.nome,
    required this.foto,
    required this.onNomeAlterado,
    required this.onFotoAlterada,
    required this.meusAnuncios,
  });

  final String nome;
  final Uint8List? foto;
  final ValueChanged<String> onNomeAlterado;
  final ValueChanged<Uint8List?> onFotoAlterada;
  final List<Publicacao> meusAnuncios;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  Future<void> _trocarFoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    widget.onFotoAlterada(bytes);
  }

  Future<void> _editarNome() async {
    final controller = TextEditingController(text: widget.nome);
    final formKey = GlobalKey<FormState>();

    final novoNome = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Trocar nome'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Informe um nome.';
                if (text.length < 2) return 'Nome muito curto.';
                return null;
              },
              onFieldSubmitted: (_) {
                final isValid = formKey.currentState?.validate() ?? false;
                if (!isValid) return;
                Navigator.of(context).pop(controller.text.trim());
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final isValid = formKey.currentState?.validate() ?? false;
                if (!isValid) return;
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    final trimmed = (novoNome ?? '').trim();
    if (trimmed.isEmpty) return;
    widget.onNomeAlterado(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final nomeExibicao = widget.nome.trim().isEmpty ? 'Seu nome' : widget.nome;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundImage:
                      widget.foto != null ? MemoryImage(widget.foto!) : null,
                  child: widget.foto == null
                      ? const Icon(Icons.person, size: 34)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeExibicao,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _trocarFoto,
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Trocar foto'),
                          ),
                          if (widget.foto != null)
                            OutlinedButton.icon(
                              onPressed: () => widget.onFotoAlterada(null),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remover'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Nome'),
                subtitle: Text(nomeExibicao),
                trailing: const Icon(Icons.edit_outlined),
                onTap: _editarNome,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Meus anúncios',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text('${widget.meusAnuncios.length}'),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.meusAnuncios.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Você ainda não publicou nenhum anúncio.'),
            ),
          )
        else
          ...widget.meusAnuncios.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PublicacaoCard(publicacao: p),
            ),
          ),
      ],
    );
  }
}
