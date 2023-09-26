import 'package:flutter/material.dart';

/// Class that represents a search field widget
class SearchFieldInput extends StatelessWidget {
  final String label;
  final Function(String)? onChanged;
  const SearchFieldInput({super.key, required this.label, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.search),
        labelText: label,
      ),
    );
  }
}
