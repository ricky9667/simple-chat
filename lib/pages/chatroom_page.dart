import 'package:flutter/material.dart';
import 'package:simple_chat/widgets/message_box.dart';

class ChatroomPage extends StatelessWidget {
  const ChatroomPage({Key? key}) : super(key: key);

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
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      MessageBox(message: 'Hi!\nThis is a message!', isSelf: false),
                      MessageBox(message: 'Hi!\nThis is a respond message!', isSelf: true),
                      MessageBox(message: 'Hi!\nThis is a message!', isSelf: false),
                      MessageBox(message: 'Hi!\nThis is a respond message!', isSelf: true),
                      MessageBox(message: 'Hi!\nThis is a message!', isSelf: false),
                      MessageBox(message: 'Hi!\nThis is a respond message!', isSelf: true),
                      MessageBox(message: 'Hi!\nThis is a message!', isSelf: false),
                      MessageBox(message: 'Hi!\nThis is a message!', isSelf: false),
                      MessageBox(message: 'Hi!\nThis is a message!', isSelf: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: TextFormField(
                      controller: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
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
                      icon: const Icon(Icons.send),
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        print('onPressed');
                      },
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

/*
Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('hello'),
                  TextFormField(
                    controller: null,
                    decoration: const InputDecoration(labelText: ''),
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                  ),
                ],
              )
 */
