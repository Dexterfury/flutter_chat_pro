import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/widgets/friend_widget.dart';
import 'package:flutter_chat_pro/widgets/settings_list_tile.dart';
import 'package:flutter_chat_pro/widgets/settings_switch_list_tile.dart';
import 'package:provider/provider.dart';

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  String getGroupAdminsNames({
    required GroupProvider groupProvider,
    required String uid,
  }) {
    // check if there are group members
    if (groupProvider.groupMembersList.isEmpty) {
      return 'To asign Admin roles, Please add group members in the previous screen';
    } else {
      List<String> groupAdminsNames = [];

      // get the list of group admins
      List<UserModel> groupAdminsList = groupProvider.groupAdminsList;

      // get a list of names from the group admins list
      List<String> groupAdminsNamesList = groupAdminsList.map((groupAdmin) {
        return groupAdmin.uid == uid ? 'You' : groupAdmin.name;
      }).toList();

      // add these names to the groupAdminsNames list
      groupAdminsNames.addAll(groupAdminsNamesList);

      // if they are just two, seperate them with 'and', if they are more than 2
      // seperate the last one with 'and' and the rest with comma
      // if (groupAdminsList.length == 1) {
      //   return groupAdminsNames.first;
      // } else if (groupAdminsNames.length == 2) {
      //   return groupAdminsNames.join(' and ');
      // } else {
      //   return '${groupAdminsNames.sublist(0, groupAdminsNames.length - 1).join(', ')} and ${groupAdminsNames.last}';
      // }
      return groupAdminsNames.length == 2
          ? '${groupAdminsNames[0]} and ${groupAdminsNames[1]}'
          : groupAdminsNames.length > 2
              ? '${groupAdminsNames.sublist(0, groupAdminsNames.length - 1).join(', ')} and ${groupAdminsNames.last}'
              : 'You';
    }
  }

  Color getAdminsContainerColor({
    required GroupProvider groupProvider,
  }) {
    // check if there are group members
    if (groupProvider.groupMembersList.isEmpty) {
      return Theme.of(context).disabledColor;
    } else {
      return Theme.of(context).cardColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    // get the list of group admins
    List<UserModel> groupAdminsList =
        context.read<GroupProvider>().groupAdminsList;

    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Group Settings'),
        ),
        body: Consumer<GroupProvider>(
          builder: (context, groupProvider, child) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Column(
                children: [
                  SettingsSwitchListTile(
                    title: 'Edit Group Settings',
                    subtitle:
                        'Only Admins can change group info, name, image and description',
                    icon: Icons.edit,
                    containerColor: Colors.green,
                    value: groupProvider.groupModel.editSettings,
                    onChanged: (value) {
                      groupProvider.setEditSettings(value: value);
                    },
                  ),
                  const SizedBox(height: 10),
                  SettingsSwitchListTile(
                    title: 'Approve New Members',
                    subtitle:
                        'New Members will be added only after admin approval',
                    icon: Icons.approval,
                    containerColor: Colors.blue,
                    value: groupProvider.groupModel.approveMembers,
                    onChanged: (value) {
                      groupProvider.setApproveNewMembers(value: value);
                    },
                  ),
                  const SizedBox(height: 10),
                  groupProvider.groupModel.approveMembers
                      ? SettingsSwitchListTile(
                          title: 'Request to Join',
                          subtitle:
                              'Request incoming members to join the group, before viewing group content',
                          icon: Icons.request_page,
                          containerColor: Colors.orange,
                          value: groupProvider.groupModel.requestToJoing,
                          onChanged: (value) {
                            groupProvider.setRequestToJoin(value: value);
                          },
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  SettingsSwitchListTile(
                    title: 'Lock Messages',
                    subtitle:
                        'Only Admins can send messages, other members can only read messages',
                    icon: Icons.lock,
                    containerColor: Colors.deepPurple,
                    value: groupProvider.groupModel.lockMessages,
                    onChanged: (value) {
                      groupProvider.setLockMessages(value: value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color:
                        getAdminsContainerColor(groupProvider: groupProvider),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: SettingsListTile(
                          title: 'Group Admins',
                          subtitle: getGroupAdminsNames(
                              groupProvider: groupProvider, uid: uid),
                          icon: Icons.admin_panel_settings,
                          iconContainerColor: Colors.red,
                          onTap: () {
                            // check if there are group members
                            if (groupProvider.groupMembersList.isEmpty) {
                              return;
                            }
                            // show bottom sheet to select admins
                            showBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.9,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Select Group Admins',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Done',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: groupProvider
                                                  .groupMembersList.length,
                                              itemBuilder: (context, index) {
                                                final friend = groupProvider
                                                    .groupMembersList[index];
                                                return FriendWidget(
                                                  friend: friend,
                                                  viewType:
                                                      FriendViewType.groupView,
                                                  isAdminView: true,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          }),
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }
}
