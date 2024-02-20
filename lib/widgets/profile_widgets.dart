import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/main_screen/friend_requests_screen.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GroupStatusWidget extends StatelessWidget {
  const GroupStatusWidget({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin;
  final GroupProvider groupProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              groupProvider.groupModel.isPrivate ? 'Private' : 'Public',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GetRequestWidget(
          groupProvider: groupProvider,
          isAdmin: isAdmin,
        ),
      ],
    );
  }
}

class ProfileStatusWidget extends StatelessWidget {
  const ProfileStatusWidget({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FriendRequestButton(
          currentUser: currentUser,
          userModel: userModel,
        ),
        const SizedBox(height: 10),
        FriendsButton(
          currentUser: currentUser,
          userModel: userModel,
        ),
      ],
    );
  }
}

class FriendsButton extends StatelessWidget {
  const FriendsButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    // friends button
    Widget buildFriendsButton() {
      if (currentUser.uid == userModel.uid &&
          userModel.friendsUIDs.isNotEmpty) {
        return MyElevatedButton(
          onPressed: () {
            // navigate to friends screen
            Navigator.pushNamed(
              context,
              Constants.friendsScreen,
            );
          },
          label: 'Friends',
          width: MediaQuery.of(context).size.width * 0.4,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary,
        );
      } else {
        if (currentUser.uid != userModel.uid) {
          // show cancle friend request button if the user sent us friend request
          // else show send friend request button
          if (userModel.friendRequestsUIDs.contains(currentUser.uid)) {
            // show send friend request button
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .cancleFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(context, 'friend request canclled');
                });
              },
              label: 'Cancle Request',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (userModel.sentFriendRequestsUIDs
              .contains(currentUser.uid)) {
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(
                      context, 'You are now friends with ${userModel.name}');
                });
              },
              label: 'Accept Friend',
              width: MediaQuery.of(context).size.width * 0.4,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyElevatedButton(
                  onPressed: () async {
                    // show unfriend dialog to ask the user if he is sure to unfriend
                    // create a dialog to confirm logout
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Unfriend',
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          'Are you sure you want to Unfriend ${userModel.name}?',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              // remove friend
                              await context
                                  .read<AuthenticationProvider>()
                                  .removeFriend(friendID: userModel.uid)
                                  .whenComplete(() {
                                showSnackBar(
                                    context, 'You are no longer friends');
                              });
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                  },
                  label: 'Unfriend',
                  width: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: Colors.deepPurple,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 10),
                MyElevatedButton(
                  onPressed: () async {
                    // navigate to chat screen
                    // navigate to chat screen with the folowing arguments
                    // 1. friend uid 2. friend name 3. friend image 4. groupId with an empty string
                    Navigator.pushNamed(context, Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: userModel.uid,
                          Constants.contactName: userModel.name,
                          Constants.contactImage: userModel.image,
                          Constants.groupId: ''
                        });
                  },
                  label: 'Chat',
                  width: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: Theme.of(context).cardColor,
                  textColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          } else {
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .sendFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(context, 'friend request sent');
                });
              },
              label: 'Send Request',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          }
        } else {
          return const SizedBox.shrink();
        }
      }
    }

    return buildFriendsButton();
  }
}

class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    // friend request button
    Widget buildFriendRequestButton() {
      if (currentUser.uid == userModel.uid &&
          userModel.friendRequestsUIDs.isNotEmpty) {
        return MyElevatedButton(
          onPressed: () {
            // navigate to friend requests screen
            Navigator.pushNamed(
              context,
              Constants.friendRequestsScreen,
            );
          },
          label: 'Requests',
          width: MediaQuery.of(context).size.width * 0.4,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary,
        );
      } else {
        // not in our profile
        return const SizedBox.shrink();
      }
    }

    return buildFriendRequestButton();
  }
}

class GetRequestWidget extends StatelessWidget {
  const GetRequestWidget({
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

    return getRequestWidget();
  }
}

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.width,
    required this.backgroundColor,
    required this.textColor,
  });

  final VoidCallback onPressed;
  final String label;
  final double width;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    Widget buildElevatedButton() {
      return SizedBox(
        //width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return buildElevatedButton();
  }
}
