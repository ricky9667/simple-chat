import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/providers/auth_provider.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: Center(
        child: ElevatedButton(
          child: Text('Logout'),
          onPressed: () {
            ref.read(authProvider.notifier).logout();
          },
        ),
      ),
    );
  }
}
