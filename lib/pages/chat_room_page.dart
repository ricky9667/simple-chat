import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/models/chat_room.dart';
import 'package:simple_chat/pages/loading_page.dart';
import 'package:simple_chat/repositories/auth/firebase_auth_repository.dart';
import 'package:simple_chat/repositories/data/firebase_data_repository.dart';
import 'package:simple_chat/widgets/message_box.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final String chatRoomId;
  final String chatRoomName;

  const ChatRoomPage({Key? key, required this.chatRoomId, required this.chatRoomName}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _textController = TextEditingController();
  final _messageScrollController = ScrollController();

  String get chatRoomId => widget.chatRoomId;

  void _scrollToBottom() {
    // if (_messageList.isNotEmpty) {
    //   _messageScrollController.animateTo(
    //     _messageScrollController.position.maxScrollExtent,
    //     duration: const Duration(seconds: 1),
    //     curve: Curves.fastOutSlowIn,
    //   );
    // }
  }

  void _submitText() async {
    final text = _textController.text.trim();
    if (text == '') return;

    await firebaseDataRepository.sendMessage(
      chatRoomId: chatRoomId,
      userId: firebaseAuthRepository.id,
      text: text,
    );
    setState(() => _textController.text = '');
  }

  void _showAddUserToChatRoomDialog(BuildContext context) async {
    final userEmailController = TextEditingController();

    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add user to chat room'),
          content: TextFormField(
            controller: userEmailController,
            decoration: const InputDecoration(labelText: 'Email'),
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (dialogResult == null) return;
    try {
      if (userEmailController.text.trim() == '') throw 'Email cannot be empty';
      await firebaseDataRepository.addUserToChatRoom(
        chatRoomId: chatRoomId,
        userEmail: userEmailController.text,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add user failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoomName),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 0, child: Text('Add user')),
              const PopupMenuItem<int>(value: 1, child: Text('Show users')),
            ],
            onSelected: (value) {
              if (value == 0) {
                _showAddUserToChatRoomDialog(context);
              } else if (value == 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature in development')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: 9,
                child: StreamBuilder<ChatRoom>(
                  stream: firebaseDataRepository.getChatRoom(chatRoomId: chatRoomId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const LoadingPage();
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('An error has occurred...'));
                    }

                    final messageList = snapshot.data!.messages;
                    if (messageList.isNotEmpty) {
                      return SingleChildScrollView(
                        controller: _messageScrollController,
                        child: Column(
                          children: messageList
                              .map(
                                (value) => MessageBox(
                                  message: value['text'],
                                  time: value['time'],
                                  isSelf: value['user'] == firebaseAuthRepository.id,
                                ),
                              )
                              .toList(),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          'Chat room is empty! Type something below!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: TextFormField(
                      controller: _textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blue,
                      ),
                      onPressed: () async => _submitText(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
