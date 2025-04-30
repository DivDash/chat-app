import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBtn extends StatefulWidget {
  final ValueChanged<bool> onSearchToggle;

  const SearchBtn({
    super.key,
    required this.onSearchToggle,
  });

  @override
  State<SearchBtn> createState() => _SearchBtnState();
}

class _SearchBtnState extends State<SearchBtn> {
  bool _isSearching = false;
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isSearching ? CupertinoIcons.clear_circled_solid : Icons.search,
      ),
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
        });
        widget.onSearchToggle(_isSearching);
      },
    );
  }
}
