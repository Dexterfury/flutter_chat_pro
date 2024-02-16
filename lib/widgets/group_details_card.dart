import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/main_screen/friend_requests_screen.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';

class GroupDetailsCard extends StatelessWidget {
  const GroupDetailsCard({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    // get requestWidget
    Widget getRequestWidget() {
      // check if user is admin
      if (isAdmin) {
        // chec if there is any request
        if (groupProvider.groupModel.awaitingApprovalUIDs.isNotEmpty) {
          return InkWell(
            onTap: () {
              // navigate to add members screen
              // navigate to friend requests screen
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FriendRequestScreen(
                  groupId: groupProvider.groupModel.groupId,
                );
              }));
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orangeAccent,
              child: Icon(
                Icons.person_add,
                color: Colors.white,
                size: 15,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      } else {
        return const SizedBox();
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                userImageWidget(
                    imageUrl: groupProvider.groupModel.groupImage,
                    radius: 50,
                    onTap: () {}),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      groupProvider.groupModel.groupName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        InkWell(
                          onTap: !isAdmin
                              ? null
                              : () {
                                  // show dialog to change group type
                                  showMyAnimatedDialog(
                                    context: context,
                                    title: 'Change Group Type',
                                    content:
                                        'Are you sure you want to change the group type to ${groupProvider.groupModel.isPrivate ? 'Public' : 'Private'}?',
                                    textAction: 'Change',
                                    onActionTap: (value) {
                                      if (value) {
                                        // change group type
                                        groupProvider.changeGroupType();
                                      }
                                    },
                                  );
                                },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isAdmin ? Colors.deepPurple : Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              groupProvider.groupModel.isPrivate
                                  ? 'Private'
                                  : 'Public',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        getRequestWidget(),
                      ],
                    ),
                  ],
                )
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            const Text('Group Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            Text(
              groupProvider.groupModel.groupDescription,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
