import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/app_bar_back_button.dart';
import 'package:flutter_chat_pro/widgets/group_details_card.dart';
import 'package:flutter_chat_pro/widgets/settings_list_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    // get user data from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: StreamBuilder(
        stream: context.read<AuthenticationProvider>().userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoDetailsCard(
                    userModel: userModel,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Settings',
                      style: GoogleFonts.openSans(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: [
                        SettingsListTile(
                          title: 'Account',
                          icon: Icons.person,
                          iconContainerColor: Colors.deepPurple,
                          onTap: () {
                            // navigate to account settings
                          },
                        ),
                        SettingsListTile(
                          title: 'My Media',
                          icon: Icons.image,
                          iconContainerColor: Colors.green,
                          onTap: () {
                            // navigate to account settings
                          },
                        ),
                        SettingsListTile(
                          title: 'Notifications',
                          icon: Icons.notifications,
                          iconContainerColor: Colors.red,
                          onTap: () {
                            // navigate to account settings
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: [
                        SettingsListTile(
                          title: 'Help',
                          icon: Icons.help,
                          iconContainerColor: Colors.yellow,
                          onTap: () {
                            // navigate to account settings
                          },
                        ),
                        SettingsListTile(
                          title: 'Share',
                          icon: Icons.share,
                          iconContainerColor: Colors.blue,
                          onTap: () {
                            // navigate to account settings
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isDarkMode
                                ? Icons.nightlight_round
                                : Icons.wb_sunny_rounded,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                      title: const Text('Change theme'),
                      trailing: Switch(
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
                          }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: [
                        SettingsListTile(
                          title: 'Logout',
                          icon: Icons.logout_outlined,
                          iconContainerColor: Colors.red,
                          onTap: () {
                            showMyAnimatedDialog(
                              context: context,
                              title: 'Logout',
                              content: 'Are you sure you want to logout?',
                              textAction: 'Logout',
                              onActionTap: (value) {
                                if (value) {
                                  // logout
                                  context
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
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
