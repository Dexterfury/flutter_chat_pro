import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/chat_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/unread_message_counter.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    required this.chatModel,
    required this.isGroup,
    required this.onTap,
  });

  final ChatModel chatModel;
  final bool isGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return ListTile(
      leading: GlobalMethods.userImageWidget(
        imageUrl: chatModel.image,
        radius: 40,
        onTap: () {},
      ),
      contentPadding: EdgeInsets.zero,
      title: Text(chatModel.name),
      subtitle: Row(
        children: [
          uid == chatModel.senderUID
              ? const Text(
                  'You:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          const SizedBox(width: 5),
          GlobalMethods.messageToShow(
            type: chatModel.messageType,
            message: chatModel.lastMessage,
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(chatModel.timeSent),
            UnreadMessageCounter(
              uid: uid,
              contactUID: chatModel.contactUID,
              isGroup: isGroup,
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
