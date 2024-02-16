import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/settings_list_tile.dart';

class ExitGroupCard extends StatelessWidget {
  const ExitGroupCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SettingsListTile(
          title: 'Exit Group',
          icon: Icons.exit_to_app,
          iconContainerColor: Colors.red,
          onTap: () {
            // exit group
            showMyAnimatedDialog(
              context: context,
              title: 'Exit Group',
              content: 'Are you sure you want to exit the group?',
              textAction: 'Exit',
              onActionTap: (value) {
                if (value) {
                  // groupProvider.exitGroup();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
