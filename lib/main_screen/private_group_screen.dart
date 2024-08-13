import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/widgets/chat_widget.dart';
import 'package:provider/provider.dart';

class PrivateGroupScreen extends StatefulWidget {
  const PrivateGroupScreen({super.key});

  @override
  State<PrivateGroupScreen> createState() => _PrivateGroupScreenState();
}

class _PrivateGroupScreenState extends State<PrivateGroupScreen> {
  String searchQuery = '';
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            placeholder: 'Search',
            onChanged: (value) => setState(() => searchQuery = value),
            onSuffixTap: () {
              setState(() => searchQuery = '');
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        if (searchQuery == '')
          MyPrivateGroups(uid: uid)
        else
          MyPrivateSearchGroups(uid: uid, searchText: searchQuery)
      ],
    ));
  }
}

class MyPrivateGroups extends StatelessWidget {
  const MyPrivateGroups({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    log('this one');
    return StreamBuilder<List<GroupModel>>(
      stream: context.read<GroupProvider>().getPrivateGroupsStream(userId: uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }
        if (snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No private groups'),
          );
        }
        return Expanded(
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final groupModel = snapshot.data![index];
              return ChatWidget(
                  group: groupModel,
                  isGroup: true,
                  onTap: () {
                    context
                        .read<GroupProvider>()
                        .setGroupModel(groupModel: groupModel)
                        .whenComplete(() {
                      Navigator.pushNamed(
                        context,
                        Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: groupModel.groupId,
                          Constants.contactName: groupModel.groupName,
                          Constants.contactImage: groupModel.groupImage,
                          Constants.groupId: groupModel.groupId,
                        },
                      );
                    });
                  });
            },
          ),
        );
      },
    );
  }
}

class MyPrivateSearchGroups extends StatelessWidget {
  const MyPrivateSearchGroups({
    super.key,
    required this.uid,
    required this.searchText,
  });

  final String uid;
  final String searchText;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupModel>>(
      stream: context.read<GroupProvider>().getPrivateGroupsStream(userId: uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        final results = snapshot.data!
            .where((element) => element.groupName
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()))
            .toList();

        if (results.isEmpty) {
          return const Center(
            child: Text('No group found'),
          );
        }

        if (results.isNotEmpty) {
          return Expanded(
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final groupModel = snapshot.data![index];
                return ChatWidget(
                    group: groupModel,
                    isGroup: true,
                    onTap: () {
                      context
                          .read<GroupProvider>()
                          .setGroupModel(groupModel: groupModel)
                          .whenComplete(() {
                        Navigator.pushNamed(
                          context,
                          Constants.chatScreen,
                          arguments: {
                            Constants.contactUID: groupModel.groupId,
                            Constants.contactName: groupModel.groupName,
                            Constants.contactImage: groupModel.groupImage,
                            Constants.groupId: groupModel.groupId,
                          },
                        );
                      });
                    });
              },
            ),
          );
        }
        return const Center(
          child: Text('No group found'),
        );
      },
    );
  }
}
