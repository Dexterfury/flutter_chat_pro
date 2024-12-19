import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/search_provider.dart';
import 'package:flutter_chat_pro/streams/data_repository.dart';
import 'package:flutter_chat_pro/widgets/friend_widget.dart';
import 'package:provider/provider.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.viewType,
    this.groupId = '',
    this.groupMembersUIDs = const [],
    this.limit = 20,
    this.isLive = true,
  });

  final FriendViewType viewType;
  final String groupId;
  final List<String> groupMembersUIDs;
  final int limit;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticationProvider, SearchProvider>(
      builder: (context, authProvider, searchProvider, child) {
        final uid = authProvider.userModel!.uid;
        final searchQuery = searchProvider.searchQuery;

        return FutureBuilder<Query>(
          future: DataRepository.getFriendsQuery(
            uid: uid,
            groupID: groupId,
            viewType: viewType,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("No data available"));
            }

            return FirestorePagination(
              limit: limit,
              isLive: isLive,
              query: snapshot.data!,
              itemBuilder: (context, documentSnapshot, index) {
                // Get the document data at index
                final documnets = documentSnapshot[index];

                // Get friend data
                final UserModel friend =
                    UserModel.fromMap(documnets.data() as Map<String, dynamic>);

                // Apply search filter, if item does not match search query, return empty widget
                if (!friend.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase())) {
                  // Check if this is the last item and no items matched the search
                  if (index == documentSnapshot.length - 1 &&
                      !documentSnapshot.any((doc) {
                        final UserModel user = UserModel.fromMap(
                            documnets.data() as Map<String, dynamic>);
                        return user.name
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());
                      })) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No Matches Found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                // Check if all friends are in group members and if yes
                // return center text thet All friends are already in group
                if (index == documentSnapshot.length - 1 &&
                    documentSnapshot.every((doc) {
                      final UserModel user = UserModel.fromMap(
                          documnets.data() as Map<String, dynamic>);
                      return groupMembersUIDs.contains(user.uid);
                    })) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'All friends are already in group',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                // Skip if friend is in group members
                if (groupMembersUIDs.isNotEmpty &&
                    groupMembersUIDs.contains(friend.uid)) {
                  return const SizedBox.shrink();
                }

                return FriendWidget(
                  friend: friend,
                  viewType: viewType,
                  groupId: groupId,
                );
              },
              initialLoader: const Center(
                child: CircularProgressIndicator(),
              ),
              onEmpty: const Center(
                child: Text('No data available'),
              ),
              bottomLoader: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
    );
  }
}
