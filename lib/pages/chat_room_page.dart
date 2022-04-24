import 'package:flutter/material.dart';
import 'package:simple_chat/widgets/message_box.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({Key? key}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _textController = TextEditingController();
  final _messageScrollController = ScrollController();
  final List<String> _messageList = [
    "B' L2 F2 L2 D' U2 R2 D2 R2 B2 R2 U' F' U R D' B' L' R U2 F2",
    "R' F R2 U2 R' F' U F R' F'",
    "R' F2 D2 L' F2 L F2 R' U2 L' R2 B2 U R2 B' D2 U2 L D2 U' F2 Uw2 F R2 Uw2 Rw2 F D L2 Uw2 B F2 U' Fw2 Rw' B2 L2 F D F2 Uw Fw' Uw Rw2 Fw' U",
    "U' Lw' Bw' Lw Rw R2 Fw F' Dw' D2 Lw2 D' Lw Dw Lw' F B2 Bw' R' Bw2 Uw2 Dw B2 U Fw' Lw' Fw2 L2 Lw2 Bw' L Lw B' Dw' B' D Fw' D L' Bw F2 L2 F L U2 D2 F' B' R' Uw' B R2 Bw' Dw U B2 Dw Fw' B Bw'",
    "F' U' Lw2 3Fw 3Uw 3Fw' L2 3Fw' D' Uw L 3Rw Bw' 3Fw L2 3Uw' Bw2 3Uw Fw2 Bw U' 3Rw2 B Fw' Uw' 3Rw U 3Uw Bw Lw' Fw 3Fw L' B2 L Rw 3Rw' Lw2 F Bw' B' 3Fw' Rw2 U Bw' Lw2 3Uw2 3Rw Fw' Bw F U Dw F' Bw2 R2 3Fw F' 3Rw2 Bw' Rw2 L' Uw2 Lw' Bw' Lw Dw Lw' U L R Dw Lw 3Rw' R2 L F2 3Fw Fw2 Lw2",
    "3Rw R Fw' 3Rw' 3Bw R' Dw' 3Uw' Rw2 L' F 3Lw2 Rw 3Dw Lw' 3Rw' Uw' D' R' D2 3Dw 3Lw2 3Uw2 3Dw2 3Fw' B Bw2 3Lw 3Fw Lw2 R2 Dw' Fw' L2 3Lw' F D' 3Bw B L2 B2 Bw' R 3Bw2 3Uw2 3Lw U' 3Rw U' R2 3Rw B2 3Fw2 Lw2 B' D2 Uw' Lw' F2 Dw F Dw2 Lw2 U Bw' R2 U2 Rw' 3Bw Lw' F2 3Fw Uw' 3Uw2 B2 Uw2 B2 Dw Uw' 3Rw U' Bw R' U2 3Rw2 Bw Fw' 3Uw 3Dw' Dw' 3Bw2 F L' Uw2 U2 F B2 U' Dw2 3Uw",
    "R-- D++ R-- D-- R++ D++ R++ D++ R-- D-- U' R++ D-- R-- D-- R++ D++ R-- D++ R++ D-- U' R++ D-- R++ D++ R-- D-- R-- D-- R++ D++ U R-- D-- R++ D-- R-- D-- R-- D++ R++ D++ U R++ D++ R-- D++ R-- D-- R-- D++ R++ D-- U' R-- D-- R-- D-- R++ D++ R++ D++ R++ D-- U' R-- D++ R-- D-- R-- D++ R++ D-- R++ D-- U'",
  ];

  void _scrollToBottom() {
    if (_messageList.isNotEmpty) {
      _messageScrollController.animateTo(
        _messageScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _submitText() {
    final text = _textController.text.trim();
    if (text == '') return;

    setState(() {
      _messageList.add(text);
      _textController.text = '';
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Name'),
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
                child: Builder(
                  builder: (context) {
                    if (_messageList.isNotEmpty) {
                      return SingleChildScrollView(
                        controller: _messageScrollController,
                        child: Column(
                          children: _messageList.map((value) => MessageBox(message: value, isSelf: true)).toList(),
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
                      onPressed: () => _submitText(),
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
