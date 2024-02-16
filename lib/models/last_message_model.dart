import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';

class LastMessageModel {
  String senderUID;
  String contactUID;
  String contactName;
  String contactImage;
  String message;
  MessageEnum messageType;
  DateTime timeSent;
  bool isSeen;

  LastMessageModel({
    required this.senderUID,
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    required this.message,
    required this.messageType,
    required this.timeSent,
    required this.isSeen,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.senderUID: senderUID,
      Constants.contactUID: contactUID,
      Constants.contactName: contactName,
      Constants.contactImage: contactImage,
      Constants.message: message,
      Constants.messageType: messageType.name,
      Constants.timeSent: timeSent.microsecondsSinceEpoch,
      Constants.isSeen: isSeen,
    };
  }

  // from map
  factory LastMessageModel.fromMap(Map<String, dynamic> map) {
    return LastMessageModel(
      senderUID: map[Constants.senderUID] ?? '',
      contactUID: map[Constants.contactUID] ?? '',
      contactName: map[Constants.contactName] ?? '',
      contactImage: map[Constants.contactImage] ?? '',
      message: map[Constants.message] ?? '',
      messageType: map[Constants.messageType].toString().toMessageEnum(),
      timeSent: DateTime.fromMicrosecondsSinceEpoch(map[Constants.timeSent]),
      isSeen: map[Constants.isSeen] ?? false,
    );
  }

  copyWith({
    required String contactUID,
    required String contactName,
    required String contactImage,
  }) {
    return LastMessageModel(
      senderUID: senderUID,
      contactUID: contactUID,
      contactName: contactName,
      contactImage: contactImage,
      message: message,
      messageType: messageType,
      timeSent: timeSent,
      isSeen: isSeen,
    );
  }
}
