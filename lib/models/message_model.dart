import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';

class MessageModel {
  final String senderUID;
  final String senderName;
  final String senderImage;
  final String contactUID;
  final String message;
  final MessageEnum messageType;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;
  final List<String> reactions;
  final List<String> isSeenBy;
  final List<String> deletedBy;

  MessageModel({
    required this.senderUID,
    required this.senderName,
    required this.senderImage,
    required this.contactUID,
    required this.message,
    required this.messageType,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
    required this.reactions,
    required this.isSeenBy,
    required this.deletedBy,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.senderUID: senderUID,
      Constants.senderName: senderName,
      Constants.senderImage: senderImage,
      Constants.contactUID: contactUID,
      Constants.message: message,
      Constants.messageType: messageType.name,
      Constants.timeSent: timeSent.millisecondsSinceEpoch,
      Constants.messageId: messageId,
      Constants.isSeen: isSeen,
      Constants.repliedMessage: repliedMessage,
      Constants.repliedTo: repliedTo,
      Constants.repliedMessageType: repliedMessageType.name,
      Constants.reactions: reactions,
      Constants.isSeenBy: isSeenBy,
      Constants.deletedBy: deletedBy,
    };
  }

  // from map
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderUID: map[Constants.senderUID] ?? '',
      senderName: map[Constants.senderName] ?? '',
      senderImage: map[Constants.senderImage] ?? '',
      contactUID: map[Constants.contactUID] ?? '',
      message: map[Constants.message] ?? '',
      messageType: map[Constants.messageType].toString().toMessageEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map[Constants.timeSent]),
      messageId: map[Constants.messageId] ?? '',
      isSeen: map[Constants.isSeen] ?? false,
      repliedMessage: map[Constants.repliedMessage] ?? '',
      repliedTo: map[Constants.repliedTo] ?? '',
      repliedMessageType:
          map[Constants.repliedMessageType].toString().toMessageEnum(),
      reactions: List<String>.from(map[Constants.reactions] ?? []),
      isSeenBy: List<String>.from(map[Constants.isSeenBy] ?? []),
      deletedBy: List<String>.from(map[Constants.deletedBy] ?? []),
    );
  }

  copyWith({required String userId}) {
    return MessageModel(
      senderUID: senderUID,
      senderName: senderName,
      senderImage: senderImage,
      contactUID: userId,
      message: message,
      messageType: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: isSeen,
      repliedMessage: repliedMessage,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
      reactions: reactions,
      isSeenBy: isSeenBy,
      deletedBy: deletedBy,
    );
  }
}
