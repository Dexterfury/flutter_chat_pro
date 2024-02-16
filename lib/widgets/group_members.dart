import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:provider/provider.dart';

class GroupMembers extends StatelessWidget {
  const GroupMembers({
    super.key,
    required this.membersUIDs,
  });

  final List<String> membersUIDs;

  @override
  Widget build(BuildContext context) {
    String getFormatedNames(List<String> names) {
      List<String> newNamesList = names.map((e) {
        return e == context.read<AuthenticationProvider>().userModel!.name
            ? 'You'
            : e;
      }).toList();
      return newNamesList.length == 2
          ? '${newNamesList[0]} and ${newNamesList[1]}'
          : newNamesList.length > 2
              ? '${newNamesList.sublist(0, newNamesList.length - 1).join(', ')} and ${newNamesList.last}'
              : newNamesList.first;
    }

    return StreamBuilder(
      stream: context
          .read<GroupProvider>()
          .streamGroupMembersData(membersUIDs: membersUIDs),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox());
        }

        final members = snapshot.data;

        // get a list of names
        final List<String> names = [];
        // loop through the members
        for (var member in members!) {
          names.add(member[Constants.name]);
        }

        return Text(
          getFormatedNames(names),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        );
      },
    );
  }
}
