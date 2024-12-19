import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/search_provider.dart';
import 'package:flutter_chat_pro/streams/chats_stream.dart';
import 'package:flutter_chat_pro/widgets/search_bar_widget.dart';
import 'package:provider/provider.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<SearchProvider>(
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
                searchQuery: searchProvider.searchQuery,
              )),
            ],
          );
        },
      ),
    );
  }
}
