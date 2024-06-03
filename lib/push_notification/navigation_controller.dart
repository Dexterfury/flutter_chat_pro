import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/main_screen/friend_requests_screen.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:provider/provider.dart';

navigationControler({
  required BuildContext context,
  required RemoteMessage message,
}) {
  switch (message.data[Constants.notificationType]) {
    case Constants.chatNotification:
      // navigate to chat screen here
      Navigator.pushNamed(
        context,
        Constants.chatScreen,
        arguments: {
          Constants.contactUID: message.data[Constants.contactUID],
          Constants.contactName: message.data[Constants.contactName],
          Constants.contactImage: message.data[Constants.contactImage],
          Constants.groupId: '',
        },
      );
      break;
    case Constants.friendRequestNotification:
      // navigate to friend requests screen
      Navigator.pushNamed(
        context,
        Constants.friendRequestsScreen,
      );
      break;
    case Constants.requestReplyNotification:
      // navigate to friend requests screen
      // navigate to friends screen
      Navigator.pushNamed(
        context,
        Constants.friendsScreen,
      );
      break;
    case Constants.groupRequestNotification:
      // navigate to friend requests screen
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return FriendRequestScreen(
          groupId: message.data[Constants.groupId],
        );
      }));
      break;

    case Constants.groupChatNotification:
      final groupModel = GroupModel.fromMap(
          message.data[Constants.groupModel] as Map<String, dynamic>);
      // navigate to group screen
      context
          .read<GroupProvider>()
          .setGroupModel(groupModel: groupModel)
          .whenComplete(() {
        Navigator.pushNamed(
          context,
          Constants.chatScreen,
          arguments: {
            Constants.contactUID: groupModel.groupId,
            Constants.contactName: groupModel.groupName,
            Constants.contactImage: groupModel.groupImage,
            Constants.groupId: groupModel.groupId,
          },
        );
      });
      break;
    // case Constants.friendRequestNotification:
    //   // navigate to friend requests screen
    //         Navigator.pushNamed(
    //           context,
    //           Constants.friendRequestsScreen,
    //         );
    // break;
    default:
      print('No Notification');
  }
}
