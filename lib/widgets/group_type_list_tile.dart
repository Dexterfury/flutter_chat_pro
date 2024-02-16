import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';

class GroupTypeListTile extends StatelessWidget {
  GroupTypeListTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  GroupType value;
  GroupType? groupValue;
  final Function(GroupType?) onChanged;

  @override
  Widget build(BuildContext context) {
    // capitalize the first letter of the title
    final capitalizedTitle = title[0].toUpperCase() + title.substring(1);
    return RadioListTile<GroupType>(
      value: value,
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.grey[200],
      contentPadding: EdgeInsets.zero,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(
        capitalizedTitle,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
