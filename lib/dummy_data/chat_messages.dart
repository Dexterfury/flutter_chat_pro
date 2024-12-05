import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/dummy_data/chat.dart';
import 'package:flutter_chat_pro/dummy_data/message_model.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key, required this.chatModel,});

  final ChatModel chatModel;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: _buildContactInfo(widget.chatModel),
        actions: [
          IconButton(onPressed: (){
            // go to zegocloud video call screen
          }, icon: const Icon(Icons.video_call))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: MessageModel.dummyData.length,
              itemBuilder: (context, index) {
                final chat = MessageModel.dummyData[index];
                // message bubbble, if is me then right, if not then left
                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: chat.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: chat.isMe ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          chat.message,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const BottomChatField(),
        ],
      ),
    );
  }
  
  _buildContactInfo(ChatModel chatModel) {
    return Row(
      children: [
        const CircleAvatar(
          child: Icon(Icons.person),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatModel.name,
              style: const TextStyle(fontSize: 16),
            ),
            const Text(
              'Online',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
  });

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  // textEditingController
  final TextEditingController _textEditingController = TextEditingController();

  // add message
  void addMessage() {
    // add message to the list
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: Theme.of(context).textTheme.titleLarge!.color!),
        ),
        //padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: TextField(
                  controller: _textEditingController,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration.collapsed(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Type a message...',
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: addMessage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).primaryColor,
                ),
                margin: const EdgeInsets.all(6.0),
                child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ));
  }
}