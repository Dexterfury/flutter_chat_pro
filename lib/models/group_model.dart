import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';

class GroupModel {
  String creatorUID;
  String groupName;
  String groupDescription;
  String groupImage;
  String groupId;
  String lastMessage;
  String senderUID;
  MessageEnum messageType;
  String messageId;
  DateTime timeSent;
  DateTime createdAt;
  bool isPrivate;
  bool editSettings;
  bool approveMembers;
  bool lockMessages;
  bool requestToJoing;
  List<String> membersUIDs;
  List<String> adminsUIDs;
  List<String> awaitingApprovalUIDs;

  GroupModel({
    required this.creatorUID,
    required this.groupName,
    required this.groupDescription,
    required this.groupImage,
    required this.groupId,
    required this.lastMessage,
    required this.senderUID,
    required this.messageType,
    required this.messageId,
    required this.timeSent,
    required this.createdAt,
    required this.isPrivate,
    required this.editSettings,
    required this.approveMembers,
    required this.lockMessages,
    required this.requestToJoing,
    required this.membersUIDs,
    required this.adminsUIDs,
    required this.awaitingApprovalUIDs,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.creatorUID: creatorUID,
      Constants.groupName: groupName,
      Constants.groupDescription: groupDescription,
      Constants.groupImage: groupImage,
      Constants.groupId: groupId,
      Constants.lastMessage: lastMessage,
      Constants.senderUID: senderUID,
      Constants.messageType: messageType.name,
      Constants.messageId: messageId,
      Constants.timeSent: timeSent.millisecondsSinceEpoch,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
      Constants.isPrivate: isPrivate,
      Constants.editSettings: editSettings,
      Constants.approveMembers: approveMembers,
      Constants.lockMessages: lockMessages,
      Constants.requestToJoing: requestToJoing,
      Constants.membersUIDs: membersUIDs,
      Constants.adminsUIDs: adminsUIDs,
      Constants.awaitingApprovalUIDs: awaitingApprovalUIDs,
    };
  }

  // from map
  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      creatorUID: map[Constants.creatorUID] ?? '',
      groupName: map[Constants.groupName] ?? '',
      groupDescription: map[Constants.groupDescription] ?? '',
      groupImage: map[Constants.groupImage] ?? '',
      groupId: map[Constants.groupId] ?? '',
      lastMessage: map[Constants.lastMessage] ?? '',
      senderUID: map[Constants.senderUID] ?? '',
      messageType: map[Constants.messageType].toString().toMessageEnum(),
      messageId: map[Constants.messageId] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(
          map[Constants.timeSent] ?? DateTime.now().millisecondsSinceEpoch),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map[Constants.createdAt] ?? DateTime.now().millisecondsSinceEpoch),
      isPrivate: map[Constants.isPrivate] ?? false,
      editSettings: map[Constants.editSettings] ?? false,
      approveMembers: map[Constants.approveMembers] ?? false,
      lockMessages: map[Constants.lockMessages] ?? false,
      requestToJoing: map[Constants.requestToJoing] ?? false,
      membersUIDs: List<String>.from(map[Constants.membersUIDs] ?? []),
      adminsUIDs: List<String>.from(map[Constants.adminsUIDs] ?? []),
      awaitingApprovalUIDs:
          List<String>.from(map[Constants.awaitingApprovalUIDs] ?? []),
    );
  }
}
