import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/models/user_model.dart';

class DataRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get chatsList qury
  static Query getChatsListQuery({
    required String userId,
    GroupModel? groupModel,
  }) {
    Query query;
    if (groupModel != null) {
      query = _firestore
          .collection(Constants.groups)
          .where(Constants.membersUIDs, arrayContains: userId)
          .where(Constants.isPrivate, isEqualTo: groupModel.isPrivate)
          .orderBy(Constants.timeSent, descending: true);
      return query;
    } else {
      query = _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .orderBy(Constants.timeSent, descending: true);
      return query;
    }
  }

  // Get all users query
  static Query getUsersQuery({required String userID}) {
    return _firestore.collection(Constants.users);
  }

  // Updated function: Return Query based on FriendViewType
  static Future<Query> getFriendsQuery({
    required String uid,
    required String groupId,
    required FriendViewType viewType,
  }) async {
    if (viewType == FriendViewType.friendRequests) {
      if (groupId.isNotEmpty) {
        // Group's awaiting approval members
        List<String> awaitingUIDs = await getGroupAwaitingUIDs(groupId);
        return _firestore
            .collection(Constants.users)
            .where(FieldPath.documentId, whereIn: awaitingUIDs);
      } else {
        // User's friend requests
        List<String> friendRequestsUIDs = await getUserFriendRequestsUIDs(uid);
        return _firestore
            .collection(Constants.users)
            .where(FieldPath.documentId, whereIn: friendRequestsUIDs);
      }
    } else {
      // User's friends
      List<String> friendsUIDs = await getUserFriendsUIDs(uid);
      return _firestore
          .collection(Constants.users)
          .where(FieldPath.documentId, whereIn: friendsUIDs);
    }
  }

  // Helper method to get awaitingApprovalUIDs for a group
  static Future<List<String>> getGroupAwaitingUIDs(String groupId) async {
    DocumentSnapshot groupDoc =
        await _firestore.collection(Constants.groups).doc(groupId).get();
    if (groupDoc.exists) {
      List<dynamic> awaitingUIDs =
          groupDoc.get(Constants.awaitingApprovalUIDs) ?? [];
      return awaitingUIDs.cast<String>();
    }
    return [];
  }

  // Helper method to get friendRequestsUIDs for a user
  static Future<List<String>> getUserFriendRequestsUIDs(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection(Constants.users).doc(uid).get();
    if (userDoc.exists) {
      List<dynamic> friendRequestsUIDs =
          userDoc.get(Constants.friendRequestsUIDs) ?? [];
      return friendRequestsUIDs.cast<String>();
    }
    return [];
  }

  // Helper method to get friendsUIDs for a user
  static Future<List<String>> getUserFriendsUIDs(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection(Constants.users).doc(uid).get();
    if (userDoc.exists) {
      List<dynamic> friendsUIDs = userDoc.get(Constants.friendsUIDs) ?? [];
      return friendsUIDs.cast<String>();
    }
    return [];
  }

  // Fetch Users based on the Query
  static Future<List<UserModel>> getUsersFromQuery(Query query) async {
    QuerySnapshot snapshot = await query.get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Example of getting friend list based on FriendViewType
  static Future<List<UserModel>> getFriendsList({
    required String uid,
    required String groupId,
    required FriendViewType viewType,
  }) async {
    Query query =
        await getFriendsQuery(uid: uid, groupId: groupId, viewType: viewType);
    return getUsersFromQuery(query);
  }
}
