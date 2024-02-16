import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';

class AddMembers extends StatelessWidget {
  const AddMembers({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
    required this.onPressed,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '2 Members',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        !isAdmin
            ? const SizedBox()
            : Row(
                children: [
                  const Text(
                    'Add Members',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    child: IconButton(
                      onPressed: onPressed,
                      icon: const Icon(Icons.person_add),
                    ),
                  )
                ],
              )
      ],
    );
  }
}
