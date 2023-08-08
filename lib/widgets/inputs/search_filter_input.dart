import 'package:flutter/material.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';

class SearchWithFilterInput extends StatelessWidget {
  final void Function() onFilter;
  final void Function(String) onSearchChanged;
  const SearchWithFilterInput({super.key, required this.onFilter, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 12,
          child: SearchFieldInput(
            label: 'Pesquisar',
            onChanged: onSearchChanged,
          ),
        ),
        Expanded(
            flex: 2,
            child: IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: onFilter,
              iconSize: 30,
            )),
      ],
    );
  }
}
