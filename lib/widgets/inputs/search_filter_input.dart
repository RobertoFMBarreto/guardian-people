import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents a search field with filter button widget
class SearchWithFilterInput extends StatelessWidget {
  final void Function() onFilter;
  final void Function(String) onSearchChanged;
  const SearchWithFilterInput({super.key, required this.onFilter, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          flex: 12,
          child: SearchFieldInput(
            label: localizations.search.capitalizeFirst!,
            onChanged: onSearchChanged,
          ),
        ),
        if (!kIsWeb)
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
