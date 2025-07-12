import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/widgets/align_message_left_widget.dart';
import 'package:flutter_chat_pro/widgets/align_message_right_widget.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:swipe_to/swipe_to.dart';

class SwipeToWidget extends StatelessWidget {
  const SwipeToWidget({
    super.key,
    required this.onRightSwipe,
    required this.message,
    required this.isMe,
    required this.isGroupChat,
    required this.controller,
  });

  final Function() onRightSwipe;
  final MessageModel message;
  final bool isMe;
  final bool isGroupChat;
  final ReactionsController controller;

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
        onRightSwipe: (details) {
          onRightSwipe();
        },
        child: isMe
            ? AlignMessageRightWidget(
                message: message,
                isGroupChat: isGroupChat,
                controller: controller,
              )
            : AlignMessageLeftWidget(
                message: message,
                isGroupChat: isGroupChat,
                controller: controller,
              ));
  }
}
