import 'dart:async';
import 'dart:developer';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/chat_model.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/chat_widget.dart';
import 'package:provider/provider.dart';

class PrivateGroupScreen extends StatefulWidget {
  const PrivateGroupScreen({super.key});

  @override
  State<PrivateGroupScreen> createState() => _PrivateGroupScreenState();
}

class _PrivateGroupScreenState extends State<PrivateGroupScreen> {
  String searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => searchQuery = query);
    });
  }

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
              onChanged: _onSearchChanged,
              onSuffixTap: () {
                setState(() => searchQuery = '');
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          Expanded(
            child: MyPrivateGroups(uid: uid, searchQuery: searchQuery),
          ),
        ],
      ),
    );
  }
}

class MyPrivateGroups extends StatelessWidget {
  const MyPrivateGroups({
    super.key,
    required this.uid,
    required this.searchQuery,
  });

  final String uid;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupModel>>(
      stream: context.read<GroupProvider>().getPrivateGroupsStream(userId: uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No private groups'));
        }

        final groups = snapshot.data!;
        final filteredGroups = searchQuery.isEmpty
            ? groups
            : groups
                .where((group) => group.groupName
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();

        if (filteredGroups.isEmpty) {
          return const Center(child: Text('No group found'));
        }

        return ListView.builder(
          itemCount: filteredGroups.length,
          itemBuilder: (context, index) {
            final groupModel = filteredGroups[index];
            final dateTime =
                formatDate(groupModel.timeSent, [hh, ':', nn, ' ', am]);

            final ChatModel chatModel = ChatModel(
              name: groupModel.groupName,
              lastMessage: groupModel.lastMessage,
              senderUID: groupModel.senderUID,
              contactUID: groupModel.groupId,
              image: groupModel.groupImage,
              messageType: groupModel.messageType,
              timeSent: dateTime,
            );
            return ChatWidget(
                chatModel: chatModel,
                isGroup: true,
                onTap: () => GlobalMethods.navigateToChatScreen(
                      context: context,
                      chatModel: chatModel,
                      groupModel: groupModel,
                    ));
          },
        );
      },
    );
  }
}
