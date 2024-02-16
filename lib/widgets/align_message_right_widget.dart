import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/widgets/display_message_type.dart';
import 'package:flutter_chat_pro/widgets/message_reply_preview.dart';
import 'package:flutter_chat_pro/widgets/stacked_reactions.dart';
import 'package:provider/provider.dart';

class AlignMessageRightWidget extends StatelessWidget {
  const AlignMessageRightWidget({
    super.key,
    required this.message,
    this.viewOnly = false,
    required this.isGroupChat,
  });

  final MessageModel message;
  final bool viewOnly;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ', am]);
    final isReplying = message.repliedTo.isNotEmpty;
    final padding = message.reactions.isNotEmpty
        ? const EdgeInsets.only(left: 20.0, bottom: 25.0)
        : const EdgeInsets.only(bottom: 0.0);

    bool messageSeen() {
      final uid = context.read<AuthenticationProvider>().userModel!.uid;
      bool isSeen = false;
      if (isGroupChat) {
        List<String> isSeenByList = message.isSeenBy;
        if (isSeenByList.contains(uid)) {
          // remove our uid then check again
          isSeenByList.remove(uid);
        }
        isSeen = isSeenByList.isNotEmpty ? true : false;
      } else {
        isSeen = message.isSeen ? true : false;
      }

      return isSeen;
    }

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          //minWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        child: Stack(
          children: [
            Padding(
              padding: padding,
              child: Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                color: Colors.deepPurple,
                child: Padding(
                  padding: message.messageType == MessageEnum.text
                      ? const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0)
                      : const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isReplying) ...[
                          MessageReplyPreview(
                            message: message,
                            viewOnly: viewOnly,
                          )
                        ],
                        DisplayMessageType(
                          message: message.message,
                          type: message.messageType,
                          color: Colors.white,
                          isReply: false,
                          viewOnly: viewOnly,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              messageSeen() ? Icons.done_all : Icons.done,
                              color:
                                  messageSeen() ? Colors.blue : Colors.white60,
                              size: 15,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 30,
              child: StackedReactionWidget(
                message: message,
                size: 20,
                onTap: () {
                  // TODO show bottom shee with list of people who reacted
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Positioned(
//                   bottom: 4,
//                   right: 10,
//                   child: Row(
//                     children: [
//                       Text(
//                         time,
//                         style: const TextStyle(
//                             color: Colors.white60, fontSize: 10),
//                       ),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       Icon(
//                         messageSeen() ? Icons.done_all : Icons.done,
//                         color: messageSeen() ? Colors.blue : Colors.white60,
//                         size: 15,
//                       ),
//                     ],
//                   ))

// isMe
//                       ? Positioned(
//                           bottom: 4,
//                           right: 90,
//                           child: StackedReactionWidget(
//                             message: element,
//                             size: 20,
//                             onTap: () {
//                               // TODO show bottom shee with list of people who reacted
//                             },
//                           ),
//                         )
//                       : Positioned(
//                           bottom: 0,
//                           left: 50,
//                           child: StackedReactionWidget(
//                             message: element,
//                             size: 20,
//                             onTap: () {
//                               // TODO show bottom shee with list of people who reacted
//                             },
//                           ),
//                         ),
