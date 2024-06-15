import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:uuid/uuid.dart';

class GroupProvider extends ChangeNotifier {
  bool _isSloading = false;
  // bool _editSettings = true;
  // bool _approveNewMembers = false;
  // bool _requestToJoin = false;
  // bool _lockMessages = false;

  GroupModel _groupModel = GroupModel(
    creatorUID: '',
    groupName: '',
    groupDescription: '',
    groupImage: '',
    groupId: '',
    lastMessage: '',
    senderUID: '',
    messageType: MessageEnum.text,
    messageId: '',
    timeSent: DateTime.now(),
    createdAt: DateTime.now(),
    isPrivate: true,
    editSettings: true,
    approveMembers: false,
    lockMessages: false,
    requestToJoing: false,
    membersUIDs: [],
    adminsUIDs: [],
    awaitingApprovalUIDs: [],
  );
  List<UserModel> _groupMembersList = [];
  List<UserModel> _groupAdminsList = [];

  List<UserModel> _tempGroupMembersList = [];
  List<UserModel> _tempGoupAdminsList = [];

  List<String> _tempGroupMemberUIDs = [];
  List<String> _tempGroupAdminUIDs = [];

  List<UserModel> _tempRemovedAdminsList = [];
  List<UserModel> _tempRemovedMembersList = [];

  List<String> _tempRemovedMemberUIDs = [];
  List<String> _tempRemovedAdminsUIDs = [];

  bool _isSaved = false;

  // getters
  bool get isSloading => _isSloading;
  // bool get editSettings => _editSettings;
  // bool get approveNewMembers => _approveNewMembers;
  // bool get requestToJoin => _requestToJoin;
  // bool get lockMessages => _lockMessages;
  GroupModel get groupModel => _groupModel;
  List<UserModel> get groupMembersList => _groupMembersList;
  List<UserModel> get groupAdminsList => _groupAdminsList;

  // firebase initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // setters
  void setIsSloading({required bool value}) {
    _isSloading = value;
    notifyListeners();
  }

  void setEditSettings({required bool value}) {
    _groupModel.editSettings = value;
    notifyListeners();
    // return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setApproveNewMembers({required bool value}) {
    _groupModel.approveMembers = value;
    notifyListeners();
    // return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setRequestToJoin({required bool value}) {
    _groupModel.requestToJoing = value;
    notifyListeners();
    // return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setLockMessages({required bool value}) {
    _groupModel.lockMessages = value;
    notifyListeners();
    // return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  // update group settings in firestore
  Future<void> updateGroupDataInFireStore() async {
    try {
      await _firestore
          .collection(Constants.groups)
          .doc(_groupModel.groupId)
          .update(groupModel.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  // set the temp lists to empty
  Future<void> setEmptyTemps() async {
    _isSaved = false;
    _tempGoupAdminsList = [];
    _tempGroupMembersList = [];
    _tempGroupMembersList = [];
    _tempGroupMembersList = [];
    _tempGroupMemberUIDs = [];
    _tempGroupAdminUIDs = [];
    _tempRemovedMemberUIDs = [];
    _tempRemovedAdminsUIDs = [];
    _tempRemovedMembersList = [];
    _tempRemovedAdminsList = [];

    notifyListeners();
  }

  // remove temp lists members from members list
  Future<void> removeTempLists({required bool isAdmins}) async {
    if (_isSaved) return;
    if (isAdmins) {
      // check if the tem admins list is not empty
      if (_tempGoupAdminsList.isNotEmpty) {
        // remove the temp admins from the main list of admins
        _groupAdminsList.removeWhere((admin) =>
            _tempGoupAdminsList.any((tempAdmin) => tempAdmin.uid == admin.uid));
        _groupModel.adminsUIDs.removeWhere((adminUid) =>
            _tempGroupAdminUIDs.any((tempUid) => tempUid == adminUid));
        notifyListeners();
      }

      //check  if the tempRemoves list is not empty
      if (_tempRemovedAdminsList.isNotEmpty) {
        // add  the temp admins to the main list of admins
        _groupAdminsList.addAll(_tempRemovedAdminsList);
        _groupModel.adminsUIDs.addAll(_tempRemovedAdminsUIDs);
        notifyListeners();
      }
    } else {
      // check if the tem members list is not empty
      if (_tempGroupMembersList.isNotEmpty) {
        // remove the temp members from the main list of members
        _groupMembersList.removeWhere((member) => _tempGroupMembersList
            .any((tempMember) => tempMember.uid == member.uid));
        _groupModel.membersUIDs.removeWhere((memberUid) =>
            _tempGroupMemberUIDs.any((tempUid) => tempUid == memberUid));
        notifyListeners();
      }

      //check if the tempRemoves list is not empty
      if (_tempRemovedMembersList.isNotEmpty) {
        // add the temp members to the main list of members
        _groupMembersList.addAll(_tempRemovedMembersList);
        _groupModel.membersUIDs.addAll(_tempGroupMemberUIDs);
        notifyListeners();
      }
    }
  }

  // check if there was a change in group members - if there was a member added or removed
  Future<void> updateGroupDataInFireStoreIfNeeded() async {
    _isSaved = true;
    notifyListeners();
    await updateGroupDataInFireStore();
  }

  // add a group member
  void addMemberToGroup({required UserModel groupMember}) {
    _groupMembersList.add(groupMember);
    _groupModel.membersUIDs.add(groupMember.uid);
    // add data to temp lists
    _tempGroupMembersList.add(groupMember);
    _tempGroupMemberUIDs.add(groupMember.uid);
    notifyListeners();

    // return if groupID is empty - meaning we are creating a new group
    // if (_groupModel.groupId.isEmpty) return;
    // updateGroupDataInFireStore();
  }

  // add a member as an admin
  void addMemberToAdmins({required UserModel groupAdmin}) {
    _groupAdminsList.add(groupAdmin);
    _groupModel.adminsUIDs.add(groupAdmin.uid);
    //  add data to temp lists
    _tempGoupAdminsList.add(groupAdmin);
    _tempGroupAdminUIDs.add(groupAdmin.uid);
    notifyListeners();

    // return if groupID is empty - meaning we are creating a new group
    // if (_groupModel.groupId.isEmpty) return;
    // updateGroupDataInFireStore();
  }

  // update image
  void setGroupImage(String groupImage) {
    _groupModel.groupImage = groupImage;
    notifyListeners();
  }

  // set group name
  void setGroupName(String groupName) {
    _groupModel.groupName = groupName;
    notifyListeners();
  }

  // set group description
  void setGroupDescription(String groupDescription) {
    _groupModel.groupDescription = groupDescription;
    notifyListeners();
  }

  Future<void> setGroupModel({required GroupModel groupModel}) async {
    log('groupChat Provider: ${groupModel.groupName}');
    _groupModel = groupModel;
    notifyListeners();
  }

  // remove member from group
  Future<void> removeGroupMember({required UserModel groupMember}) async {
    _groupMembersList.remove(groupMember);
    // also remove this member from admins list if he is an admin
    _groupAdminsList.remove(groupMember);
    _groupModel.membersUIDs.remove(groupMember.uid);

    // remo from temp lists
    _tempGroupMembersList.remove(groupMember);
    _tempGroupAdminUIDs.remove(groupMember.uid);

    // add  this member to the list of removed members
    _tempRemovedMembersList.add(groupMember);
    _tempRemovedMemberUIDs.add(groupMember.uid);

    notifyListeners();

    // return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  // remove admin from group
  void removeGroupAdmin({required UserModel groupAdmin}) {
    _groupAdminsList.remove(groupAdmin);
    _groupModel.adminsUIDs.remove(groupAdmin.uid);
    // remo from temp lists
    _tempGroupAdminUIDs.remove(groupAdmin.uid);
    _groupModel.adminsUIDs.remove(groupAdmin.uid);

    // add the removed admins to temp removed lists
    _tempRemovedAdminsList.add(groupAdmin);
    _tempRemovedAdminsUIDs.add(groupAdmin.uid);
    notifyListeners();

    // return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  // get a list of goup members data from firestore
  Future<List<UserModel>> getGroupMembersDataFromFirestore({
    required bool isAdmin,
  }) async {
    try {
      List<UserModel> membersData = [];

      // get the list of membersUIDs
      List<String> membersUIDs =
          isAdmin ? _groupModel.adminsUIDs : _groupModel.membersUIDs;

      for (var uid in membersUIDs) {
        var user = await _firestore.collection(Constants.users).doc(uid).get();
        membersData.add(UserModel.fromMap(user.data()!));
      }

      return membersData;
    } catch (e) {
      return [];
    }
  }

  // update the groupMembersList
  Future<void> updateGroupMembersList() async {
    _groupMembersList.clear();

    _groupMembersList
        .addAll(await getGroupMembersDataFromFirestore(isAdmin: false));

    notifyListeners();
  }

  // update the groupAdminsList
  Future<void> updateGroupAdminsList() async {
    _groupAdminsList.clear();

    _groupAdminsList
        .addAll(await getGroupMembersDataFromFirestore(isAdmin: true));

    notifyListeners();
  }

  // clear group members list
  Future<void> clearGroupMembersList() async {
    _groupMembersList.clear();
    _groupAdminsList.clear();
    _groupModel = GroupModel(
      creatorUID: '',
      groupName: '',
      groupDescription: '',
      groupImage: '',
      groupId: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageId: '',
      timeSent: DateTime.now(),
      createdAt: DateTime.now(),
      isPrivate: true,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoing: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );
    notifyListeners();
  }

  // clear group admins list
  // Future<void> clearGroupAdminsList() async {
  //   _groupAdminsList.clear();
  //   notifyListeners();
  // }

  // get a list UIDs from group members list
  List<String> getGroupMembersUIDs() {
    return _groupMembersList.map((e) => e.uid).toList();
  }

  // get a list UIDs from group admins list
  List<String> getGroupAdminsUIDs() {
    return _groupAdminsList.map((e) => e.uid).toList();
  }

  // stream group data
  Stream<DocumentSnapshot> groupStream({required String groupId}) {
    return _firestore.collection(Constants.groups).doc(groupId).snapshots();
  }

  // stream users data from fireStore
  streamGroupMembersData({required List<String> membersUIDs}) {
    return Stream.fromFuture(Future.wait<DocumentSnapshot>(
      membersUIDs.map<Future<DocumentSnapshot>>((uid) async {
        return await _firestore.collection(Constants.users).doc(uid).get();
      }),
    ));
  }

  // create group
  Future<void> createGroup({
    required GroupModel newGroupModel,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    setIsSloading(value: true);

    try {
      var groupId = const Uuid().v4();
      newGroupModel.groupId = groupId;

      // check if the file image is null
      if (fileImage != null) {
        // upload image to firebase storage
        final String imageUrl = await storeFileToStorage(
            file: fileImage, reference: '${Constants.groupImages}/$groupId');
        newGroupModel.groupImage = imageUrl;
      }

      // add the group admins
      newGroupModel.adminsUIDs = [
        newGroupModel.creatorUID,
        ...getGroupAdminsUIDs()
      ];

      // add the group members
      newGroupModel.membersUIDs = [
        newGroupModel.creatorUID,
        ...getGroupMembersUIDs()
      ];

      // update the global groupModel
      setGroupModel(groupModel: newGroupModel);

      // // add edit settings
      // groupModel.editSettings = editSettings;

      // // add approve new members
      // groupModel.approveMembers = approveNewMembers;

      // // add request to join
      // groupModel.requestToJoing = requestToJoin;

      // // add lock messages
      // groupModel.lockMessages = lockMessages;

      // add group to firebase
      await _firestore
          .collection(Constants.groups)
          .doc(groupId)
          .set(groupModel.toMap());

      // set loading
      setIsSloading(value: false);
      // set onSuccess
      onSuccess();
    } catch (e) {
      setIsSloading(value: false);
      onFail(e.toString());
    }
  }

  // get a stream all private groups that contains the our userId
  Stream<List<GroupModel>> getPrivateGroupsStream({required String userId}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.membersUIDs, arrayContains: userId)
        .where(Constants.isPrivate, isEqualTo: true)
        .snapshots()
        .asyncMap((event) {
      List<GroupModel> groups = [];
      for (var group in event.docs) {
        groups.add(GroupModel.fromMap(group.data()));
      }

      return groups;
    });
  }

  // get a stream all public groups that contains the our userId
  Stream<List<GroupModel>> getPublicGroupsStream({required String userId}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.isPrivate, isEqualTo: false)
        .snapshots()
        .asyncMap((event) {
      List<GroupModel> groups = [];
      for (var group in event.docs) {
        groups.add(GroupModel.fromMap(group.data()));
      }

      return groups;
    });
  }

  // change group type
  void changeGroupType() {
    _groupModel.isPrivate = !_groupModel.isPrivate;
    notifyListeners();
    updateGroupDataInFireStore();
  }

  // send request to join group
  Future<void> sendRequestToJoinGroup({
    required String groupId,
    required String uid,
    required String groupName,
    required String groupImage,
  }) async {
    await _firestore.collection(Constants.groups).doc(groupId).update({
      Constants.awaitingApprovalUIDs: FieldValue.arrayUnion([uid])
    });

    // TODO  send notification to group admins
  }

  // accept request to join group
  Future<void> acceptRequestToJoinGroup({
    required String groupId,
    required String friendID,
  }) async {
    await _firestore.collection(Constants.groups).doc(groupId).update({
      Constants.membersUIDs: FieldValue.arrayUnion([friendID]),
      Constants.awaitingApprovalUIDs: FieldValue.arrayRemove([friendID])
    });

    _groupModel.awaitingApprovalUIDs.remove(friendID);
    _groupModel.membersUIDs.add(friendID);
    notifyListeners();
  }

  // check if is sender or admin
  bool isSenderOrAdmin({required MessageModel message, required String uid}) {
    if (message.senderUID == uid) {
      return true;
    } else if (_groupModel.adminsUIDs.contains(uid)) {
      return true;
    } else {
      return false;
    }
  }

  // exit group
  Future<void> exitGroup({
    required String uid,
  }) async {
    // check if the user is the admin of the group
    bool isAdmin = _groupModel.adminsUIDs.contains(uid);

    await _firestore
        .collection(Constants.groups)
        .doc(_groupModel.groupId)
        .update({
      Constants.membersUIDs: FieldValue.arrayRemove([uid]),
      Constants.adminsUIDs:
          isAdmin ? FieldValue.arrayRemove([uid]) : _groupModel.adminsUIDs,
    });

    // remove the user from group members list
    _groupMembersList.removeWhere((element) => element.uid == uid);
    // remove the user from group members uid
    _groupModel.membersUIDs.remove(uid);
    if (isAdmin) {
      // remove the user from group admins list
      _groupAdminsList.removeWhere((element) => element.uid == uid);
      // remove the user from group admins uid
      _groupModel.adminsUIDs.remove(uid);
    }
    notifyListeners();
  }
}
