import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';

class GoupMembersCard extends StatefulWidget {
  const GoupMembersCard({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin;
  final GroupProvider groupProvider;

  @override
  State<GoupMembersCard> createState() => _GoupMembersCardState();
}

class _GoupMembersCardState extends State<GoupMembersCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          FutureBuilder<List<UserModel>>(
            future: widget.groupProvider.getGroupMembersDataFromFirestore(
              isAdmin: false,
            ),
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
                  child: Text('No members'),
                );
              }
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final member = snapshot.data![index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: userImageWidget(
                          imageUrl: member.image, radius: 40, onTap: () {}),
                      title: Text(member.name),
                      subtitle: Text(member.aboutMe),
                      trailing: widget.groupProvider.groupModel.adminsUIDs
                              .contains(member.uid)
                          ? const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.orangeAccent,
                            )
                          : const SizedBox(),
                      onTap: !widget.isAdmin
                          ? null
                          : () {
                              // show dialog to remove member
                              showMyAnimatedDialog(
                                context: context,
                                title: 'Remove Member',
                                content:
                                    'Are you sure you want to remove ${member.name} from the group?',
                                textAction: 'Remove',
                                onActionTap: (value) async {
                                  if (value) {
                                    //remove member from group
                                    await widget.groupProvider
                                        .removeGroupMember(
                                      groupMember: member,
                                    );

                                    setState(() {});
                                  }
                                },
                              );
                            },
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
