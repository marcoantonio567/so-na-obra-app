import 'package:flutter/material.dart';

import '../models/publicacao.dart';
import '../utils/formatters.dart';

class AnuncioDetalhePage extends StatelessWidget {
  const AnuncioDetalhePage({super.key, required this.publicacao});

  final Publicacao publicacao;

  @override
  Widget build(BuildContext context) {
    final precoText = formatMoneyBRL(publicacao.preco);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do anúncio')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (publicacao.imagens.isNotEmpty)
                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: publicacao.imagens.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  publicacao.imagens[index],
                                  width: 220,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          height: 220,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        publicacao.nome,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        precoText,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(publicacao.descricao),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.storefront_outlined),
                        title: const Text('Vendedor'),
                        subtitle: Text(publicacao.criadoPorNome),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Publicado em'),
                        subtitle: Text(formatDateBR(publicacao.criadoEm)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fluxo de compra iniciado.'),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Comprar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Abrindo chat com ${publicacao.criadoPorNome}...',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Enviar chat para o vendedor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
