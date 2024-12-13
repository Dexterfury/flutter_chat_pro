import 'package:flutter_chat_pro/enums/enums.dart';

class ChatModel {
  String name;
  String lastMessage;
  String senderUID;
  String contactUID; // doubles as groupID if group
  String image;
  MessageEnum messageType;
  String timeSent;

  // Constructor
  ChatModel({
    required this.name,
    required this.lastMessage,
    required this.senderUID,
    required this.contactUID,
    required this.image,
    required this.messageType,
    required this.timeSent,
  });

  // // To map
  // Map<String, dynamic> toMap() {
  //   return {
  //     Constants.name: name,
  //     Constants.lastMessage: lastMessage,
  //     Constants.senderUID: senderUID,
  //     Constants.contactUID: contactUID,
  //     Constants.image: image,
  //     Constants.messageType: messageType.name,
  //     Constants.timeSent: timeSent,

  //   };
  // }

  // // From map
  // factory ChatModel.fromMap(Map<String, dynamic> json) {
  //   return ChatModel(
  //     name: json[Constants.name],
  //     lastMessage: json[Constants.lastMessage],
  //     senderUID: json[Constants.senderUID],
  //     contactUID: json[Constants.contactUID],
  //     image: json[Constants.image],
  //     timeSent: json[Constants.timeSent],
  //     messageType: json[Constants.messageType],
  //   );
  // }
}
