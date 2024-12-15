import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/search_provider.dart';
import 'package:provider/provider.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.placeholder = 'Search',
  });

  final Function(String) onChanged;
  final String placeholder;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    resetSearchText();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  // Rest the search text in provider
  void resetSearchText() {
    // make sure the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().clearSearchQuery();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: CupertinoSearchTextField(
        controller: _textEditingController,
        placeholder: widget.placeholder,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        onChanged: widget.onChanged,
        onSuffixTap: () {
          FocusScope.of(context).unfocus();
          _textEditingController.clear();
          resetSearchText();
        },
      ),
    );
  }
}
