import 'dart:async';
import 'package:flutter/cupertino.dart';

class SearchProvider extends ChangeNotifier {
  String _searchQuery = '';

  Timer? _debounce;

  // getters
  String get searchQuery => _searchQuery;

  // set search query
  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      notifyListeners();
    });
  }

  // clear search query
  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
