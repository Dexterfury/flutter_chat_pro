import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/streams/all_people_search_stream.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  String searchQuery = '';
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          // cupertino search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              placeholder: 'Search',
              onChanged: (value) => setState(() => searchQuery = value),
              onSuffixTap: () {
                setState(() => searchQuery = '');
                FocusScope.of(context).unfocus();
              },
            ),
          ),

          // list of users
          Expanded(
            child: searchQuery.isEmpty
                ? const Center(
                    child: Text(
                      'Search People',
                    ),
                  )
                : AllPeopleSearchStream(
                    uid: currentUser.uid,
                    searchText: searchQuery,
                  ),
          ),
        ],
      ),
    ));
  }
}
