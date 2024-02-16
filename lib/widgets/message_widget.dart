import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/widgets/swipe_to_widget.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.onRightSwipe,
    required this.isMe,
    required this.isGroupChat,
  });

  final MessageModel message;
  final Function() onRightSwipe;
  final bool isMe;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    return SwipeToWidget(
      onRightSwipe: onRightSwipe,
      message: message,
      isMe: isMe,
      isGroupChat: isGroupChat,
    );
  }
}
