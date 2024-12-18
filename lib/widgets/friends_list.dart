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
            viewType: viewType,
            groupId: groupId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            return FirestorePagination(
              limit: limit,
              isLive: isLive,
              query: snapshot.data!,
              itemBuilder: (context, documentSnapshot, index) {
                final document = documentSnapshot[index];
                final UserModel friend =
                    UserModel.fromMap(document.data() as Map<String, dynamic>);

                // Apply search filter
                if (!friend.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase())) {
                  if (index == documentSnapshot.length - 1 &&
                      !documentSnapshot.any((doc) {
                        final user = UserModel.fromMap(
                            doc.data() as Map<String, dynamic>);
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

                // Check if all friends are in group
                if (index == documentSnapshot.length - 1 &&
                    documentSnapshot.every((doc) {
                      final user =
                          UserModel.fromMap(doc.data() as Map<String, dynamic>);
                      return groupMembersUIDs.contains(user.uid);
                    })) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'All your friends are already in this group',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                // Skip if friend is already in group
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
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No Friends Yet'),
                ),
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
