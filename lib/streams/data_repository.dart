import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';

class DataRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get chatsList qury
  static Query getChatsListQuery({
    required String userId,
    required GroupType group,
  }) {
    Query query;
    switch (group) {
      case GroupType.private:
        query = _firestore
            .collection(Constants.groups)
            .where(Constants.membersUIDs, arrayContains: userId)
            .where(Constants.isPrivate, isEqualTo: true)
            .orderBy(Constants.timeSent, descending: true);
        return query;
      case GroupType.public:
        query = _firestore
            .collection(Constants.groups)
            .where(Constants.membersUIDs, arrayContains: userId)
            .where(Constants.isPrivate, isEqualTo: false)
            .orderBy(Constants.timeSent, descending: true);
        return query;
      case GroupType.none:
        query = _firestore
            .collection(Constants.users)
            .doc(userId)
            .collection(Constants.chats)
            .orderBy(Constants.timeSent, descending: true);
        return query;
      default:
        query = _firestore
            .collection(Constants.users)
            .doc(userId)
            .collection(Constants.chats)
            .orderBy(Constants.timeSent, descending: true);
        return query;
    }
  }
}
