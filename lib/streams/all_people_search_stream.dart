import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/widgets/friend_widget.dart';

class AllPeopleSearchStream extends StatelessWidget {
  const AllPeopleSearchStream({
    super.key,
    required this.uid,
    required this.searchText,
  });

  final String uid;
  final String searchText;

  @override
  Widget build(BuildContext context) {
    // stream the last message collection
    final stream =
        FirebaseFirestore.instance.collection(Constants.users).snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (builderContext, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final results = snapshot.data!.docs
              .where((element) => element[Constants.name]
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
              .toList();

          if (results.isEmpty) {
            return const Center(
              child: Text('No chats found'),
            );
          }

          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final doc = results.elementAt(index);
                final data = doc.data() as Map<String, dynamic>;
                final item = UserModel.fromMap(data);
                if (item.uid == uid) {
                  return Container(); // skip the current user from the list
                }
                return FriendWidget(
                  friend: item,
                  viewType: FriendViewType.allUsers,
                );
              },
            );
          }
          return const Center(
            child: Text('No user found'),
          );
        });
  }
}
