import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/providers/search_provider.dart';
import 'package:flutter_chat_pro/widgets/friends_list.dart';
import 'package:flutter_chat_pro/widgets/search_bar_widget.dart';
import 'package:provider/provider.dart';

class MyDialogs {
  // animated dialog
  static void showMyAnimatedDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String textAction,
    required Function(bool, String) onActionTap,
    bool editable = false,
    String hintText = '',
  }) {
    TextEditingController controller = TextEditingController(text: hintText);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
              child: AlertDialog(
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
                content: editable
                    ? TextField(
                        controller: controller,
                        maxLength: content == Constants.changeName ? 20 : 500,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: hintText,
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    : Text(
                        content,
                        textAlign: TextAlign.center,
                      ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onActionTap(
                        false,
                        controller.text,
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onActionTap(
                        true,
                        controller.text,
                      );
                    },
                    child: Text(textAction),
                  ),
                ],
              ),
            ));
      },
    );
  }

// show bottom sheet with the list of all app users to add them to the group
  static void showAddMembersBottomSheet({
    required BuildContext context,
    required List<String> groupMembersUIDs,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PopScope(
          onPopInvokedWithResult: (bool didPop, dynamic results) async {
            if (!didPop) return;
            // do something when the bottom sheet is closed.
            await context
                .read<GroupProvider>()
                .removeTempLists(isAdmins: false);
          },
          child: SizedBox(
            height: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SearchBarWidget(
                          onChanged: (value) {
                            context
                                .read<SearchProvider>()
                                .setSearchQuery(value);
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context
                              .read<GroupProvider>()
                              .updateGroupDataInFireStoreIfNeeded()
                              .whenComplete(() {
                            // close bottom sheet
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          });
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 2,
                  color: Colors.grey,
                ),
                Expanded(
                  child: FriendsList(
                    viewType: FriendViewType.groupView,
                    groupMembersUIDs: groupMembersUIDs,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Deletion bottom sheet
  static void deletionBottomSheet({
    required BuildContext context,
    required MessageModel message,
    required String currentUserId,
    required bool isSenderOrAdmin,
    required String contactUID,
    required String groupId,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
        return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
          return SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (chatProvider.isLoading) const LinearProgressIndicator(),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete for me'),
                    onTap: chatProvider.isLoading
                        ? null
                        : () async {
                            await chatProvider
                                .deleteMessage(
                              currentUserId: currentUserId,
                              contactUID: contactUID,
                              messageId: message.messageId,
                              messageType: message.messageType.name,
                              isGroupChat: groupId.isNotEmpty,
                              deleteForEveryone: false,
                            )
                                .whenComplete(() {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            });
                          },
                  ),
                  isSenderOrAdmin
                      ? ListTile(
                          leading: const Icon(Icons.delete_forever),
                          title: const Text('Delete for everyone'),
                          onTap: chatProvider.isLoading
                              ? null
                              : () async {
                                  await chatProvider
                                      .deleteMessage(
                                    currentUserId: currentUserId,
                                    contactUID: contactUID,
                                    messageId: message.messageId,
                                    messageType: message.messageType.name,
                                    isGroupChat: groupId.isNotEmpty,
                                    deleteForEveryone: true,
                                  )
                                      .whenComplete(() {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  });
                                },
                        )
                      : const SizedBox.shrink(),
                  ListTile(
                    leading: const Icon(Icons.cancel),
                    title: const Text('cancel'),
                    onTap: chatProvider.isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
