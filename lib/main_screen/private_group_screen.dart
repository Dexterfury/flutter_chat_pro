import 'dart:async';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/chat_model.dart';
import 'package:flutter_chat_pro/models/group_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/providers/search_provider.dart';
import 'package:flutter_chat_pro/streams/chats_stream.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/chat_widget.dart';
import 'package:flutter_chat_pro/widgets/search_bar_widget.dart';
import 'package:provider/provider.dart';

class PrivateGroupScreen extends StatefulWidget {
  const PrivateGroupScreen({super.key});

  @override
  State<PrivateGroupScreen> createState() => _PrivateGroupScreenState();
}

class _PrivateGroupScreenState extends State<PrivateGroupScreen> {
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
                onClear: () {
                  searchProvider.clearSearchQuery();
                  FocusScope.of(context).unfocus();
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

// class MyPrivateGroups extends StatelessWidget {
//   const MyPrivateGroups({
//     super.key,
//     required this.uid,
//     required this.searchQuery,
//   });

//   final String uid;
//   final String searchQuery;

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<GroupModel>>(
//       stream: context.read<GroupProvider>().getPrivateGroupsStream(userId: uid),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return const Center(child: Text('Something went wrong'));
//         }
//         if (snapshot.data!.isEmpty) {
//           return const Center(child: Text('No private groups'));
//         }

//         final groups = snapshot.data!;
//         final filteredGroups = searchQuery.isEmpty
//             ? groups
//             : groups
//                 .where((group) => group.groupName
//                     .toLowerCase()
//                     .contains(searchQuery.toLowerCase()))
//                 .toList();

//         if (filteredGroups.isEmpty) {
//           return const Center(child: Text('No group found'));
//         }

//         return ListView.builder(
//           itemCount: filteredGroups.length,
//           itemBuilder: (context, index) {
//             final groupModel = filteredGroups[index];
//             final dateTime =
//                 formatDate(groupModel.timeSent, [hh, ':', nn, ' ', am]);

//             final ChatModel chatModel = ChatModel(
//               name: groupModel.groupName,
//               lastMessage: groupModel.lastMessage,
//               senderUID: groupModel.senderUID,
//               contactUID: groupModel.groupId,
//               image: groupModel.groupImage,
//               messageType: groupModel.messageType,
//               timeSent: dateTime,
//             );
//             return ChatWidget(
//                 chatModel: chatModel,
//                 isGroup: true,
//                 onTap: () => GlobalMethods.navigateToChatScreen(
//                       context: context,
//                       chatModel: chatModel,
//                       groupModel: groupModel,
//                     ));
//           },
//         );
//       },
//     );
//   }
// }
