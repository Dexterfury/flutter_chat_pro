import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/streams/data_repository.dart';
import 'package:flutter_chat_pro/widgets/friend_widget.dart';

class AllUsersList extends StatelessWidget {
  const AllUsersList({
    super.key,
    required this.userID,
    required this.searchQuery,
  });

  final String userID;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return FirestorePagination(
      limit: 20,
      isLive: true,
      query: DataRepository.getUsersQuery(
        userID: userID,
      ),
      itemBuilder: (context, documentSnapshot, index) {
        // Get the document data at index
        final documnets = documentSnapshot[index];

        // Get user data
        final user =
            UserModel.fromMap(documnets.data()! as Map<String, dynamic>);

        // Apply search filter, if item does not match search query, return empty widget
        if (!user.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          // Check if this is the last item and no items matched the search
          if (index == documentSnapshot.length - 1 &&
              !documentSnapshot.any((doc) {
                return user.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
              })) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No Users Found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        // hide our data from the list
        if (user.uid == userID) {
          return const SizedBox.shrink();
        }

        return FriendWidget(friend: user, viewType: FriendViewType.allUsers);
      },
      initialLoader: const Center(
        child: CircularProgressIndicator(),
      ),
      onEmpty: const Center(
        child: Text('No Users Yet'),
      ),
      bottomLoader: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
