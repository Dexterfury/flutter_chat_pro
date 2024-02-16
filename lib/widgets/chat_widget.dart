import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/models/last_message_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/unread_message_counter.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    this.chat,
    this.group,
    required this.isGroup,
    required this.onTap,
  });

  final LastMessageModel? chat;
  final GroupModel? group;
  final bool isGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    // get the last message
    final lastMessage = chat != null ? chat!.message : group!.lastMessage;
    // get the senderUID
    final senderUID = chat != null ? chat!.senderUID : group!.senderUID;

    // get the date and time
    final timeSent = chat != null ? chat!.timeSent : group!.timeSent;
    final dateTime = formatDate(timeSent, [hh, ':', nn, ' ', am]);

    // get the image url
    final imageUrl = chat != null ? chat!.contactImage : group!.groupImage;

    // get the name
    final name = chat != null ? chat!.contactName : group!.groupName;

    // get the contactUID
    final contactUID = chat != null ? chat!.contactUID : group!.groupId;
    // get the messageType
    final messageType = chat != null ? chat!.messageType : group!.messageType;
    return ListTile(
      leading: userImageWidget(
        imageUrl: imageUrl,
        radius: 40,
        onTap: () {},
      ),
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Row(
        children: [
          uid == senderUID
              ? const Text(
                  'You:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          const SizedBox(width: 5),
          messageToShow(
            type: messageType,
            message: lastMessage,
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dateTime),
            UnreadMessageCounter(
              uid: uid,
              contactUID: contactUID,
              isGroup: isGroup,
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
