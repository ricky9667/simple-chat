import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key, required this.message, required this.isSelf}) : super(key: key);

  final String message;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    if (isSelf) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          child: Text(message),
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
