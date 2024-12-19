import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/group_model.dart';

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

  // Get friends query based on FriendViewType
  static Future<Query> getFriendsQuery({
    required String uid,
    required String groupID,
    required FriendViewType viewType,
  }) async {
    if (viewType == FriendViewType.friendRequests) {
      if (groupID.isEmpty) {
        // Group's awaiting approval members
        List<String> awaitingUIDs =
            await getGroupAwaitingUIDs(groupID: groupID);

        return _firestore
            .collection(Constants.users)
            .where(FieldPath.documentId, whereIn: awaitingUIDs);
      } else {
        // User's friend requests
        List<String> friendRequestsUIDs =
            await getUsersFriendRequestsUIDs(uid: uid);
        return _firestore
            .collection(Constants.users)
            .where(FieldPath.documentId, whereIn: friendRequestsUIDs);
      }
    } else {
      // User's friends
      List<String> friendsUIDs = await getUsersFriendsUIDs(uid: uid);
      return _firestore
          .collection(Constants.users)
          .where(FieldPath.documentId, whereIn: friendsUIDs);
    }
  }

  // Helper method to get group awaiting approval members
  static Future<List<String>> getGroupAwaitingUIDs(
      {required String groupID}) async {
    DocumentSnapshot groupDoc =
        await _firestore.collection(Constants.groups).doc(groupID).get();
    if (groupDoc.exists) {
      List<dynamic> awaitingUIDs =
          groupDoc.get(Constants.awaitingApprovalUIDs) ?? [];
      return awaitingUIDs.cast<String>();
    }

    return [];
  }

  // Helper method to get user's friend requests
  static Future<List<String>> getUsersFriendRequestsUIDs(
      {required String uid}) async {
    DocumentSnapshot userDoc =
        await _firestore.collection(Constants.users).doc(uid).get();
    if (userDoc.exists) {
      List<dynamic> friendRequestsUIDs =
          userDoc.get(Constants.friendRequestsUIDs) ?? [];
      return friendRequestsUIDs.cast<String>();
    }
    return [];
  }

  // Helper method to get user's friends
  static Future<List<String>> getUsersFriendsUIDs({required String uid}) async {
    DocumentSnapshot userDoc =
        await _firestore.collection(Constants.users).doc(uid).get();
    if (userDoc.exists) {
      List<dynamic> friendsUIDs = userDoc.get(Constants.friendsUIDs) ?? [];
      return friendsUIDs.cast<String>();
    }

    return [];
  }
}
