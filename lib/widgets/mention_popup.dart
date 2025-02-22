import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/user_model.dart';

class MentionPopup extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onUserSelected;
  final double width;

  const MentionPopup({
    super.key,
    required this.users,
    required this.onUserSelected,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: width,
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.image),
              ),
              title: Text(user.name),
              onTap: () => onUserSelected(user),
            );
          },
        ),
      ),
    );
  }
}
