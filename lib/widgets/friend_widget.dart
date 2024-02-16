import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class FriendWidget extends StatelessWidget {
  const FriendWidget({
    super.key,
    required this.friend,
    required this.viewType,
    this.isAdminView = false,
    this.groupId = '',
  });

  final UserModel friend;
  final FriendViewType viewType;
  final bool isAdminView;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthenticationProvider>().userModel!.uid;
    final name = uid == friend.uid ? 'You' : friend.name;
    bool getValue() {
      return isAdminView
          ? context.watch<GroupProvider>().groupAdminsList.contains(friend)
          : context.watch<GroupProvider>().groupMembersList.contains(friend);
    }

    return ListTile(
      minLeadingWidth: 0.0,
      contentPadding: const EdgeInsets.only(left: -10),
      leading:
          userImageWidget(imageUrl: friend.image, radius: 40, onTap: () {}),
      title: Text(name),
      subtitle: Text(
        friend.aboutMe,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: viewType == FriendViewType.friendRequests
          ? ElevatedButton(
              onPressed: () async {
                if (groupId.isEmpty) {
                  // accept friend request
                  await context
                      .read<AuthenticationProvider>()
                      .acceptFriendRequest(friendID: friend.uid)
                      .whenComplete(() {
                    showSnackBar(
                        context, 'You are now friends with ${friend.name}');
                  });
                } else {
                  // accept group request
                  await context
                      .read<GroupProvider>()
                      .acceptRequestToJoinGroup(
                        groupId: groupId,
                        friendID: friend.uid,
                      )
                      .whenComplete(() {
                    Navigator.pop(context);
                    showSnackBar(context,
                        '${friend.name} is now a member of this group');
                  });
                }
              },
              child: const Text('Accept'),
            )
          : viewType == FriendViewType.groupView
              ? Checkbox(
                  value: getValue(),
                  onChanged: (value) {
                    // check the check box
                    if (isAdminView) {
                      if (value == true) {
                        context
                            .read<GroupProvider>()
                            .addMemberToAdmins(groupAdmin: friend);
                      } else {
                        context
                            .read<GroupProvider>()
                            .removeGroupAdmin(groupAdmin: friend);
                      }
                    } else {
                      if (value == true) {
                        context
                            .read<GroupProvider>()
                            .addMemberToGroup(groupMember: friend);
                      } else {
                        context
                            .read<GroupProvider>()
                            .removeGroupMember(groupMember: friend);
                      }
                    }
                  },
                )
              : null,
      onTap: () {
        if (viewType == FriendViewType.friends) {
          // navigate to chat screen with the folowing arguments
          // 1. friend uid 2. friend name 3. friend image 4. groupId with an empty string
          Navigator.pushNamed(context, Constants.chatScreen, arguments: {
            Constants.contactUID: friend.uid,
            Constants.contactName: friend.name,
            Constants.contactImage: friend.image,
            Constants.groupId: ''
          });
        } else if (viewType == FriendViewType.allUsers) {
          // navite to this user's profile screen
          Navigator.pushNamed(
            context,
            Constants.profileScreen,
            arguments: friend.uid,
          );
        } else {
          if (groupId.isNotEmpty) {
            // navigate to this person's profile
            Navigator.pushNamed(
              context,
              Constants.profileScreen,
              arguments: friend.uid,
            );
          }
        }
      },
    );
  }
}
