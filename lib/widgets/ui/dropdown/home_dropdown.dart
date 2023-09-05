import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeDropDown extends StatelessWidget {
  const HomeDropDown({super.key});

  void _onSelectedItem(int item, BuildContext context) {
    switch (item) {
      case 0:
        Navigator.of(context).pushNamed('/profile');
        break;
      case 1:
        //! Logout code
        clearUserSession().then(
          (value) => Navigator.of(context).popAndPushNamed('/login'),
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
