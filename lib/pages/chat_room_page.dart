import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/models/chat_room.dart';
import 'package:simple_chat/models/user.dart';
import 'package:simple_chat/pages/loading_page.dart';
import 'package:simple_chat/repositories/auth/firebase_auth_repository.dart';
import 'package:simple_chat/repositories/data/firebase_data_repository.dart';
import 'package:simple_chat/widgets/message_box.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final ChatRoom chatRoom;

  const ChatRoomPage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _textController = TextEditingController();
  final _messageScrollController = ScrollController();
  final Map<String, User> _chatRoomUsers = {};

  String get chatRoomId => widget.chatRoom.id;

  @override
  void initState() {
    super.initState();
    // _updateChatRoomUsersData(widget.chatRoom.users).then((value) => null);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _messageScrollController.jumpTo(_messageScrollController.position.maxScrollExtent);
    });
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

  void _showChatRoomUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chat room users'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _chatRoomUsers.keys.map((value) {
                final user = _chatRoomUsers[value]!;
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _showLeaveRoomDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chat room users'),
          content: const SingleChildScrollView(
            child: Text('Are you sure you want to leave this chat room?'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await firebaseDataRepository.leaveChatRoom(chatRoomId: chatRoomId, userId: firebaseAuthRepository.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _submitText() async {
    final text = _textController.text.trim();
    if (text == '') return;

    await firebaseDataRepository.sendMessage(
      chatRoomId: chatRoomId,
      userId: firebaseAuthRepository.id,
      text: text,
    );
    setState(() {
      _textController.text = '';
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        _messageScrollController.animateTo(
          _messageScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      });
    });
  }

  Future<void> _updateChatRoomUsersData(List<String> userIdList) async {
    _chatRoomUsers.clear();
    for (final userId in userIdList) {
      final user = await firebaseDataRepository.getUser(userId: userId);
      _chatRoomUsers[userId] = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatRoom>(
      stream: firebaseDataRepository.getChatRoom(chatRoomId: chatRoomId),
      initialData: widget.chatRoom,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoadingPage();
        } else if (snapshot.hasError) {
          return const Center(child: Text('An error has occurred...'));
        } else {
          final chatRoom = snapshot.data!;
          _updateChatRoomUsersData(chatRoom.users);

          return Scaffold(
            appBar: AppBar(
              title: Text(chatRoom.name),
              actions: [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(value: 0, child: Text('Add user')),
                    const PopupMenuItem<int>(value: 1, child: Text('Show users')),
                    const PopupMenuItem<int>(value: 2, child: Text('Leave room')),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                        _showAddUserToChatRoomDialog(context);
                        break;
                      case 1:
                        _showChatRoomUsersDialog(context);
                        break;
                      case 2:
                        _showLeaveRoomDialog(context);
                        break;
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
                      child: snapshot.data!.messages.isEmpty
                          ? Center(
                              child: Text(
                                'Chat room is empty! Type something below!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : SingleChildScrollView(
                              controller: _messageScrollController,
                              child: Column(
                                children: chatRoom.messages.map((value) {
                                  return MessageBox(
                                    message: value['text'],
                                    name: 'Name',
                                    time: value['time'],
                                    isSelf: value['user'] == firebaseAuthRepository.id,
                                  );
                                }).toList(),
                              ),
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
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
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
                            icon: const Icon(Icons.send, color: Colors.blue),
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
      },
    );
  }
}
