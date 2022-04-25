import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBox extends StatelessWidget {
  final String message;
  final String name;
  final Timestamp time;
  final bool isSelf;

  final _messageTopLabelStyle = TextStyle(color: Colors.grey[600], fontSize: 12);
  final timeFormat = DateFormat('kk:mm');

  MessageBox({Key? key, required this.message, required this.name, required this.time, required this.isSelf})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(time.toDate().toString());
    final labelText = isSelf ? '${timeFormat.format(dateTime)} $name' : '$name ${timeFormat.format(dateTime)}';
    return Align(
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text(labelText, style: _messageTopLabelStyle),
          Container(
            child: Text(message, style: TextStyle(color: isSelf ? Colors.white : Colors.black)),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
            decoration: BoxDecoration(
              color: isSelf ? Colors.blue : Colors.white,
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
