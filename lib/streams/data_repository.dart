import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_pro/constants.dart';
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
}
