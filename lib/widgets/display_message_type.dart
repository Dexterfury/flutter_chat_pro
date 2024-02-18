import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/widgets/audio_player_widget.dart';
import 'package:flutter_chat_pro/widgets/video_player_widget.dart';

class DisplayMessageType extends StatelessWidget {
  const DisplayMessageType({
    super.key,
    required this.message,
    required this.type,
    required this.color,
    required this.isReply,
    this.maxLines,
    this.overFlow,
    required this.viewOnly,
  });

  final String message;
  final MessageEnum type;
  final Color color;
  final bool isReply;
  final int? maxLines;
  final TextOverflow? overFlow;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    Widget messageToShow() {
      switch (type) {
        case MessageEnum.text:
          return Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 16.0,
            ),
            maxLines: maxLines,
            overflow: overFlow,
          );
        case MessageEnum.image:
          return isReply
              ? const Icon(Icons.image)
              : CachedNetworkImage(
                  width: 200,
                  height: 200,
                  imageUrl: message,
                  fit: BoxFit.cover,
                );
        case MessageEnum.video:
          return isReply
              ? const Icon(Icons.video_collection)
              : VideoPlayerWidget(
                  videoUrl: message,
                  color: color,
                  viewOnly: viewOnly,
                );
        case MessageEnum.audio:
          return isReply
              ? const Icon(Icons.audiotrack)
              : AudioPlayerWidget(
                  audioUrl: message,
                  color: color,
                  viewOnly: viewOnly,
                );
        default:
          return Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 16.0,
            ),
            maxLines: maxLines,
            overflow: overFlow,
          );
      }
    }

    return messageToShow();
  }
}
