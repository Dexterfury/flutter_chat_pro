import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/search_provider.dart';
import 'package:flutter_chat_pro/streams/chats_stream.dart';
import 'package:flutter_chat_pro/widgets/search_bar_widget.dart';
import 'package:provider/provider.dart';

class PrivateGroupScreen extends StatelessWidget {
  const PrivateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return SafeArea(
      child: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return Column(
            children: [
              // Search bar
              SearchBarWidget(
                onChanged: (value) {
                  searchProvider.setSearchQuery(value);
                },
              ),

              Expanded(
                  child: ChatsStream(
                uid: uid,
                groupModel: GroupModel.empty(isPrivate: true),
                searchQuery: searchProvider.searchQuery,
              )),
            ],
          );
        },
      ),
    );
  }
}
