import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/chat_model.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/models/last_message_model.dart';
import 'package:flutter_chat_pro/streams/data_repository.dart';
import 'package:flutter_chat_pro/widgets/chat_widget.dart';

class ChatsStream extends StatelessWidget {
  const ChatsStream({
    super.key,
    required this.uid,
    required this.group,
    this.searchQuery = '',
    this.limit = 20,
    this.isLive = true,
  });

  final String uid;
  final GroupType group;
  final String searchQuery;
  final int limit;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return FirestorePagination(
        limit: limit,
        isLive: isLive,
        query: DataRepository.getChatsListQuery(userId: uid, group: group),
        itemBuilder: (context, documentSnapshot, index) {
          // Get the document data at index
          final documnets = documentSnapshot[index];

          // Get chat data from document
          final ChatModel chatModel = getChatData(documnets, group);

          // Apply search filter, if item does not match search query, return empty widget
          if (!chatModel.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
            // Check if this is the last item and no items matched the search
            if (index == documentSnapshot.length - 1 &&
                !documentSnapshot.any((doc) {
                  final model = getChatData(doc, group);
                  return model.name
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                })) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No Matches Found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          return ChatWidget(
            chatModel: chatModel,
            isGroup: group != GroupType.none,
            onTap: () {
              Navigator.pushNamed(
                context,
                Constants.chatScreen,
                arguments: {
                  Constants.contactUID: chatModel.contactUID,
                  Constants.contactName: chatModel.name,
                  Constants.contactImage: chatModel.image,
                  Constants.groupId: '',
                },
              );
            },
          );
        },
        initialLoader: const Center(
          child: CircularProgressIndicator(),
        ),
        onEmpty: const Center(
          child: Text('No Chats Yet'),
        ),
        bottomLoader: const Center(
          child: CircularProgressIndicator(),
        ));
  }
}

ChatModel getChatData(
  DocumentSnapshot<Object?> documnets,
  GroupType group,
) {
  if (group == GroupType.none) {
    LastMessageModel chat =
        LastMessageModel.fromMap(documnets.data() as Map<String, dynamic>);
    final dateTime = formatDate(chat.timeSent, [hh, ':', nn, ' ', am]);
    final senderUID = chat.senderUID;
    final messageType = chat.messageType;

    ChatModel chatModel = ChatModel(
      name: chat.contactName,
      lastMessage: chat.message,
      senderUID: senderUID,
      contactUID: chat.contactUID,
      image: chat.contactImage,
      messageType: messageType,
      timeSent: dateTime,
    );
    return chatModel;
  } else {
    GroupModel chat =
        GroupModel.fromMap(documnets.data() as Map<String, dynamic>);
    final dateTime = formatDate(chat.timeSent, [hh, ':', nn, ' ', am]);
    final senderUID = chat.senderUID;
    final messageType = chat.messageType;
    ChatModel chatModel = ChatModel(
      name: chat.groupName,
      lastMessage: chat.lastMessage,
      senderUID: senderUID,
      contactUID: chat.groupId,
      image: chat.groupImage,
      messageType: messageType,
      timeSent: dateTime,
    );

    return chatModel;
  }
}
