import 'package:flutter/material.dart';

import 'chats/chat_list_tile.dart';
import 'chats/chat_seed.dart';
import 'chats/chat_thread_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: conversasFicticias.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final chat = conversasFicticias[index];
            return ChatListTile(
              chat: chat,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChatThreadPage(chat: chat),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
