import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/models/message_reply_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/streams/data_repository.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/utilities/my_dialogs.dart';
import 'package:flutter_chat_pro/widgets/align_message_left_widget.dart';
import 'package:flutter_chat_pro/widgets/align_message_right_widget.dart';
import 'package:flutter_chat_pro/widgets/date_widget.dart';
import 'package:flutter_chat_pro/widgets/message_widget.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.contactUID,
    required this.groupId,
  });

  final String contactUID;
  final String groupId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    if (_scrollController.hasClients) _scrollController.dispose();
    super.dispose();
  }

  void onContextMenyClicked(
      {required String item, required MessageModel message}) {
    switch (item) {
      case 'Reply':
        // set the message reply to true
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          messageType: message.messageType,
          isMe: true,
        );

        context.read<ChatProvider>().setMessageReplyModel(messageReply);
        break;
      case 'Copy':
        // copy message to clipboard
        Clipboard.setData(ClipboardData(text: message.message));
        GlobalMethods.showSnackBar(context, 'Message copied to clipboard');
        break;
      case 'Delete':
        final currentUserId =
            context.read<AuthenticationProvider>().userModel!.uid;
        final groupProvider = context.read<GroupProvider>();

        if (widget.groupId.isNotEmpty) {
          if (groupProvider.isSenderOrAdmin(
              message: message, uid: currentUserId)) {
            showDeletBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: true,
            );
            return;
          } else {
            showDeletBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: false,
            );
            return;
          }
        }
        showDeletBottomSheet(
          message: message,
          currentUserId: currentUserId,
          isSenderOrAdmin: true,
        );
        break;
    }
  }

  // Delet bottom sheet
  void showDeletBottomSheet({
    required MessageModel message,
    required String currentUserId,
    required bool isSenderOrAdmin,
  }) {
    MyDialogs.deletionBottomSheet(
      context: context,
      message: message,
      currentUserId: currentUserId,
      isSenderOrAdmin: isSenderOrAdmin,
      contactUID: widget.contactUID,
      groupId: widget.groupId,
    );
  }

  void sendReactionToMessage(
      {required String reaction, required String messageId}) {
    // get the sender uid
    final senderUID = context.read<AuthenticationProvider>().userModel!.uid;

    context.read<ChatProvider>().sendReactionToMessage(
          senderUID: senderUID,
          contactUID: widget.contactUID,
          messageId: messageId,
          reaction: reaction,
          groupId: widget.groupId.isNotEmpty,
        );
  }

  void showEmojiContainer({required String messageId}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context);
            // add emoji to message
            sendReactionToMessage(
              reaction: emoji.emoji,
              messageId: messageId,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // current user uid
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return FirestorePagination(
      limit: 20,
      isLive: true,
      reverse: true,
      controller: _scrollController,
      query: DataRepository.getMessagesQuery(
        userId: uid,
        contactUID: widget.contactUID,
        isGroup: widget.groupId.isNotEmpty,
      ),
      itemBuilder: (context, documentSnapshot, index) {
        // Chat provider
        final chatProvider = context.read<ChatProvider>();
        // Get the message data at index
        final message = MessageModel.fromMap(
            documentSnapshot[index].data()! as Map<String, dynamic>);

        // check if we sent the last message
        final isMe = message.senderUID == uid;

        // if the deletedBy contains the current user id then dont show the message
        if (message.deletedBy.contains(uid)) {
          return const SizedBox.shrink();
        }

        // Date header logic here
        Widget? dateHeader;
        if (index < documentSnapshot.length - 1) {
          final nextMessage = MessageModel.fromMap(
            documentSnapshot[index + 1].data()! as Map<String, dynamic>,
          );

          if (!GlobalMethods.isSameDay(
            message.timeSent,
            nextMessage.timeSent,
          )) {
            dateHeader = DateWidget(message: message);
          }
        } else if (index == documentSnapshot.length - 1) {
          dateHeader = DateWidget(message: message);
        }

        // check if its groupChat
        if (widget.groupId.isNotEmpty) {
          chatProvider.setMessageStatus(
            currentUserId: uid,
            contactUID: widget.contactUID,
            messageId: message.messageId,
            isSeenByList: message.isSeenBy,
            isGroupChat: widget.groupId.isNotEmpty,
          );
        } else {
          if (!message.isSeen && message.senderUID != uid) {
            chatProvider.setMessageStatus(
              currentUserId: uid,
              contactUID: widget.contactUID,
              messageId: message.messageId,
              isSeenByList: message.isSeenBy,
              isGroupChat: widget.groupId.isNotEmpty,
            );
          }
        }

        return Column(
          children: [
            if (dateHeader != null) dateHeader,
            GestureDetector(
              onLongPress: () async {
                Navigator.of(context).push(
                  HeroDialogRoute(builder: (context) {
                    return ReactionsDialogWidget(
                      id: message.messageId,
                      messageWidget: isMe
                          ? AlignMessageRightWidget(
                              message: message,
                              viewOnly: true,
                              isGroupChat: widget.groupId.isNotEmpty,
                            )
                          : AlignMessageLeftWidget(
                              message: message,
                              viewOnly: true,
                              isGroupChat: widget.groupId.isNotEmpty,
                            ),
                      onReactionTap: (reaction) {
                        if (reaction == '➕') {
                          showEmojiContainer(
                            messageId: message.messageId,
                          );
                        } else {
                          sendReactionToMessage(
                            reaction: reaction,
                            messageId: message.messageId,
                          );
                        }
                      },
                      onContextMenuTap: (item) {
                        onContextMenyClicked(
                          item: item.label,
                          message: message,
                        );
                      },
                      widgetAlignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                    );
                  }),
                );
              },
              child: Hero(
                tag: message.messageId,
                child: MessageWidget(
                  message: message,
                  onRightSwipe: () {
                    // set the message reply to true
                    final messageReply = MessageReplyModel(
                      message: message.message,
                      senderUID: message.senderUID,
                      senderName: message.senderName,
                      senderImage: message.senderImage,
                      messageType: message.messageType,
                      isMe: isMe,
                    );

                    context
                        .read<ChatProvider>()
                        .setMessageReplyModel(messageReply);
                  },
                  isMe: isMe,
                  isGroupChat: widget.groupId.isNotEmpty,
                ),
              ),
            ),
          ],
        );
      },
      initialLoader: const Center(
        child: CircularProgressIndicator(),
      ),
      onEmpty: Center(
        child: Text(
          'Start a conversation',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
              fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      bottomLoader: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
