import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/widgets/audio_player_widget.dart';
import 'package:flutter_chat_pro/widgets/video_player_widget.dart';

class DisplayMessageType extends StatelessWidget {
  const DisplayMessageType({
    super.key,
    required this.message,
    required this.isGroupChat,
    required this.color,
    required this.isReply,
    this.maxLines,
    this.overFlow,
    required this.viewOnly,
  });

  final MessageModel message;
  final bool isGroupChat;
  final Color color;
  final bool isReply;
  final int? maxLines;
  final TextOverflow? overFlow;
  final bool viewOnly;

  Color _getMentionColor(String mention) {
    return Colors.blue;
  }

  Widget _buildMessageText(BuildContext context) {
    if (!isGroupChat) {
      return Text(
        message.message,
        style: TextStyle(
          color: color,
          fontSize: 16.0,
          overflow: overFlow,
        ),
      );
    }

    final words = message.message.split(' ');
    List<TextSpan> spans = [];

    for (final word in words) {
      if (word.startsWith('@')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: TextStyle(
              fontSize: 16.0,
              color: _getMentionColor(word.substring(1)),
              fontWeight: FontWeight.bold,
              overflow: overFlow,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: '$word '));
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: color),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget messageToShow() {
      switch (message.messageType) {
        case MessageEnum.text:
          return _buildMessageText(context);
        case MessageEnum.image:
          return isReply
              ? const Icon(Icons.image)
              : CachedNetworkImage(
                  width: 200,
                  height: 200,
                  imageUrl: message.message,
                  fit: BoxFit.cover,
                );
        case MessageEnum.video:
          return isReply
              ? const Icon(Icons.video_collection)
              : VideoPlayerWidget(
                  videoUrl: message.message,
                  color: color,
                  viewOnly: viewOnly,
                );
        case MessageEnum.audio:
          return isReply
              ? const Icon(Icons.audiotrack)
              : AudioPlayerWidget(
                  audioUrl: message.message,
                  color: color,
                  viewOnly: viewOnly,
                );
      }
    }

    return messageToShow();
  }
}
