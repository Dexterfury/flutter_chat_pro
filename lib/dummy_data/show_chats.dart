import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/dummy_data/chat.dart';
import 'package:flutter_chat_pro/dummy_data/chat_messages.dart';

class MyChats extends StatefulWidget {
  const MyChats({super.key});

  @override
  State<MyChats> createState() => _MyChatsState();
}

class _MyChatsState extends State<MyChats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Widget'),
      ),
      body: ListView.builder(
        itemCount: ChatModel.dummyData.length,
        itemBuilder: (context, index) {
          final chat = ChatModel.dummyData[index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(chat.name),
            subtitle: Text(chat.latestMessage),
            trailing: Text(chat.time),
            onTap: (){
              // navigate to chat messages screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatMessages(chatModel: chat,)));
            },
          );
        })
    );
  }
}
