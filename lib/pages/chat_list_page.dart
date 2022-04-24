import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/pages/chat_room_page.dart';
import 'package:simple_chat/pages/loading_page.dart';
import 'package:simple_chat/providers/auth_provider.dart';
import 'package:simple_chat/repositories/auth/firebase_auth_repository.dart';
import 'package:simple_chat/repositories/data/firebase_data_repository.dart';

final _chatRoomsProvider = StreamProvider((ref) {
  final user = ref.watch(authProvider).user;
  print('Current user: ${user.id}');
  return firebaseDataRepository.getChatRooms(userId: user.id);
});

class ChatListPage extends ConsumerWidget {
  const ChatListPage({Key? key}) : super(key: key);

  void _createChatroom(BuildContext context) async {
    final roomNameController = TextEditingController();

    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create new chat room'),
          content: TextFormField(
            controller: roomNameController,
            decoration: const InputDecoration(labelText: 'Room name'),
            autocorrect: false,
            keyboardType: TextInputType.text,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (dialogResult == null) return;
    await firebaseDataRepository.createChatroom(
      name: roomNameController.text.trim(),
      userIdList: [firebaseAuthRepository.id],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRooms = ref.watch(_chatRoomsProvider);

    return chatRooms.when(
      data: (data) => Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Sign out'),
                ),
              ],
              onSelected: (value) {
                if (value == 0) {
                  ref.read(authProvider.notifier).logout();
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _createChatroom(context),
        ),
        body: SafeArea(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final chatRoom = data[index];
              final lastMessage = chatRoom.messages.isEmpty ? '(Empty)' : chatRoom.messages.last;
              return ListTile(
                leading: const Icon(Icons.account_circle, size: 40),
                title: Text(chatRoom.name),
                subtitle: Text('$lastMessage'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatRoomPage(chatRoomId: chatRoom.id)),
                ),
              );
            },
          ),
        ),
      ),
      error: (error, _) => SelectableText('Load courses error: $error'),
      loading: () => const LoadingPage(),
    );
  }
}
