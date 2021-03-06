import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/pages/chat_room_page.dart';
import 'package:simple_chat/pages/loading_page.dart';
import 'package:simple_chat/providers/auth_provider.dart';
import 'package:simple_chat/repositories/auth/firebase_auth_repository.dart';
import 'package:simple_chat/repositories/data/firebase_data_repository.dart';
import 'package:url_launcher/url_launcher.dart';

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
      if (roomNameController.text.trim() == '') throw 'Room name cannot be empty';
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

  Future<void> _openGithubRepository() async {}

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

  void _showDeleteChatRoomDialog(BuildContext context, String chatRoomId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete chat room'),
          content: const SingleChildScrollView(
            child: Text(
              'Are you sure?\nAll your messages will be deleted.',
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                firebaseDataRepository.deleteChatRoom(chatRoomId: chatRoomId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                const PopupMenuItem<int>(value: 0, child: Text('About')),
                const PopupMenuItem<int>(value: 1, child: Text('Show profile')),
                const PopupMenuItem<int>(value: 2, child: Text('Sign out')),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 0:
                    if (!await launchUrl(Uri.parse('https://github.com/ricky9667/simple-chat'))) {
                      throw 'Could not launch website';
                    }
                    break;
                  case 1:
                    _showProfileDialog(context);
                    break;
                  case 2:
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
          child: data.isEmpty
              ? Center(
                  child: Text(
                    'Add a new chat room from the + button below!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final chatRoom = data[index];
                    final lastMessage = chatRoom.messages.isEmpty ? '(Empty)' : chatRoom.messages.last['text'];
                    return ListTile(
                      leading: const Icon(Icons.account_circle, size: 40),
                      title: Text(chatRoom.name),
                      subtitle: Text('$lastMessage'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomPage(chatRoom: chatRoom),
                        ),
                      ),
                      onLongPress: () => _showDeleteChatRoomDialog(context, chatRoom.id),
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
