import 'dart:io';

import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    required this.onPressed,
    this.actions = const [],
  });

  final Widget title;
  final VoidCallback onPressed;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios_new,
        ),
      ),
      title: title,
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
