import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({ Key? key, required this.onSubmit }) : super(key: key);

  final Function(String)? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Search'
        ),
        onFieldSubmitted: onSubmit,
        autofocus: false
      )
    );
  }
}