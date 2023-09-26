import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeDropDown extends StatelessWidget {
  const HomeDropDown({super.key});

  void _onSelectedItem(int item, BuildContext context) {
    switch (item) {
      case 0:
        Navigator.push(
          context,
          CustomPageRouter(
            page: '/profile',
          ),
        );

        break;
      case 1:
        clearUserSession().then(
          (_) => deleteEverything().then(
            (_) => Navigator.pushNamedAndRemoveUntil(
                context, '/login', (Route<dynamic> route) => false),
          ),
        );

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.brightness == Brightness.light ? Colors.white : Colors.black,
      icon: Icon(
        Icons.menu,
        color: theme.colorScheme.onSecondary,
      ),
      onSelected: (item) {
        _onSelectedItem(item, context);
      },
      itemBuilder: (BuildContext context) => [
        if (hasConnection)
          PopupMenuItem(
            value: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(localizations.profile.capitalize()),
                const Icon(
                  Icons.person,
                  size: 15,
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(localizations.logout.capitalize()),
              const Icon(
                Icons.logout,
                size: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
