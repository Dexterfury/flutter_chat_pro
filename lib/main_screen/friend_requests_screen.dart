import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/widgets/app_bar_back_button.dart';
import 'package:flutter_chat_pro/widgets/friends_list.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key, this.groupId = ''});

  final String groupId;

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // cupertinosearchbar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                print(value);
              },
            ),

            Expanded(
                child: FriendsList(
              viewType: FriendViewType.friendRequests,
              groupId: widget.groupId,
            )),
          ],
        ),
      ),
    );
  }
}
