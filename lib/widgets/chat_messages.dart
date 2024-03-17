import 'package:chatapp/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages yet'),
            );
          }
          if (snapshots.hasError) {
            return const Center(
              child: Text('Something went wrong!'),
            );
          }
          final messages = snapshots.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = messages[index].data();
              final nextMsg = index + 1 < messages.length
                  ? messages[index + 1].data()
                  : null;
              final currMsgUserId = chatMessage['userId'];
              final nextMsgUserId = nextMsg != null ? nextMsg['userId'] : null;
              final isSameUser = currMsgUserId == nextMsgUserId;
              if (isSameUser) {
                return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authenticatedUser!.uid == chatMessage['userId'],
                );
              } else {
                return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser!.uid == chatMessage['userId'],
                );
              }
            },
          );
        });
  }
}
