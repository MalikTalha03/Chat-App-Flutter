import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _enteredMessage = TextEditingController();
  @override
  void dispose() {
    _enteredMessage.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final msg = _enteredMessage.text;
    if (msg.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _enteredMessage.clear();
    final user = FirebaseAuth.instance.currentUser;
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': msg,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userdata.data()!['username'],
      'userImage': userdata.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _enteredMessage,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(
                labelText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
