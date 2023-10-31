import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/main.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the home dropdown widget
class HomeDropDown extends StatelessWidget {
  const HomeDropDown({super.key});

  /// Method that redirects the user to the correct page based on [item]
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
                Text(localizations.profile.capitalizeFirst!),
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
              Text(localizations.logout.capitalizeFirst!),
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
