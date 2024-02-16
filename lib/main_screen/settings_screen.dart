import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/widgets/app_bar_back_button.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  // get the saved theme mode
  void getThemeMode() async {
    // get the saved theme mode
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    // check if the saved theme mode is dark
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      // set the isDarkMode to true
      setState(() {
        isDarkMode = true;
      });
    } else {
      // set the isDarkMode to false
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    // get the uid from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        appBar: AppBar(
          leading: AppBarBackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: const Text('Settings'),
          actions: [
            currentUser.uid == uid
                ?
                // logout button
                IconButton(
                    onPressed: () async {
                      // create a dialog to confirm logout
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // logout
                                await context
                                    .read<AuthenticationProvider>()
                                    .logout()
                                    .whenComplete(() {
                                  Navigator.pop(context);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    Constants.loginScreen,
                                    (route) => false,
                                  );
                                });
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                  )
                : const SizedBox(),
          ],
        ),
        body: Center(
          child: Card(
              child: SwitchListTile(
            title: const Text('Change Theme'),
            secondary: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                child: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  color: isDarkMode ? Colors.black : Colors.white,
                )),
            value: isDarkMode,
            onChanged: (value) {
              // set the isDarkMode to the value
              setState(() {
                isDarkMode = value;
              });
              // check if the value is true
              if (value) {
                // set the theme mode to dark
                AdaptiveTheme.of(context).setDark();
              } else {
                // set the theme mode to light
                AdaptiveTheme.of(context).setLight();
              }
            },
          )),
        ));
  }
}
