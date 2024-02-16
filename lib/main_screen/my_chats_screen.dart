import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/last_message_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/widgets/chat_widget.dart';
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
      body: Column(
        children: [
          // cupertinosearchbar
          CupertinoSearchTextField(
            placeholder: 'Search',
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              print(value);
            },
          ),

          Expanded(
            child: StreamBuilder<List<LastMessageModel>>(
              stream: context.read<ChatProvider>().getChatsListStream(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  final chatsList = snapshot.data!;
                  return ListView.builder(
                    itemCount: chatsList.length,
                    itemBuilder: (context, index) {
                      final chat = chatsList[index];

                      return ChatWidget(
                        chat: chat,
                        isGroup: false,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Constants.chatScreen,
                            arguments: {
                              Constants.contactUID: chat.contactUID,
                              Constants.contactName: chat.contactName,
                              Constants.contactImage: chat.contactImage,
                              Constants.groupId: '',
                            },
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(
                  child: Text('No chats yet'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
