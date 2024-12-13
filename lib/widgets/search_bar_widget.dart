import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.onChanged,
    required this.onClear,
    this.placeholder = 'Search',
  });

  final Function(String) onChanged;
  final VoidCallback onClear;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: CupertinoSearchTextField(
        placeholder: placeholder,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        onChanged: onChanged,
        onSuffixTap: onClear,
      ),
    );
  }
}
