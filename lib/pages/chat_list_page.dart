import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/pages/chat_room_page.dart';
import 'package:simple_chat/pages/loading_page.dart';
import 'package:simple_chat/providers/auth_provider.dart';
import 'package:simple_chat/repositories/auth/firebase_auth_repository.dart';
import 'package:simple_chat/repositories/data/firebase_data_repository.dart';

final _chatRoomsProvider = StreamProvider((ref) {
  final user = ref.watch(authProvider).user;
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

    try {
      await firebaseDataRepository.createChatRoom(
        name: roomNameController.text.trim(),
        userIdList: [firebaseAuthRepository.id],
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create chat room failed: $error')),
      );
    }
  }

  void _showProfileDialog(BuildContext context) async {
    final user = await firebaseDataRepository.getUser(userId: firebaseAuthRepository.id);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Your Profile'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user.name}'),
                const SizedBox(height: 12),
                Text('Email: ${user.email}'),
                const SizedBox(height: 12),
                Text('Uid: ${user.id}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ok'),
            ),
          ],
        );
      },
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
                const PopupMenuItem<int>(value: 0, child: Text('Show profile')),
                const PopupMenuItem<int>(value: 1, child: Text('Sign out')),
              ],
              onSelected: (value) {
                switch (value) {
                  case 0:
                    _showProfileDialog(context);
                    break;
                  case 1:
                    ref.read(authProvider.notifier).logout();
                    break;
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
              final lastMessage = chatRoom.messages.isEmpty ? 'Empty' : chatRoom.messages.last['text'];
              return ListTile(
                leading: const Icon(Icons.account_circle, size: 40),
                title: Text(chatRoom.name),
                subtitle: Text('$lastMessage'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomPage(
                      chatRoomId: chatRoom.id,
                      chatRoomName: chatRoom.name,
                    ),
                  ),
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
