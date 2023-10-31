import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/operations/user_operations.dart';
import 'package:get/get.dart';
import 'package:guardian/models/providers/session_provider.dart';

/// Class that represents the welcome page
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    _getToken(context);

    super.initState();
  }

  /// Method that gets the user id and the session token redirecting afterwards to the correct home page
  ///
  /// In case the user id or token are null the user is sent to login
  Future<void> _getToken(BuildContext context) async {
    await getUid(context).then(
      (idUser) async {
        if (idUser != null) {
          // get user data
          getUser(idUser).then((user) {
            // TODO: To Remove it
            // loadUserDevices(idUser);
            //loadUserFences(idUser);
            // loadAlerts();

            // if there is stored data use it for getting his role
            if (user != null) {
              Navigator.pushReplacement(
                context,
                CustomPageRouter(page: user.isSuperuser ? '/admin' : '/producer'),
              );
            } else {
              Navigator.pushReplacement(
                context,
                CustomPageRouter(page: '/login'),
              );
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            theme.brightness == Brightness.dark ? gdDarkGradientStart : gdGradientStart,
            theme.brightness == Brightness.dark ? gdDarkGradientEnd : gdGradientEnd,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor:
              Theme.of(context).brightness == Brightness.light ? gdGradientEnd : gdDarkGradientEnd,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                flex: 10,
                child: Center(
                  child: Text(
                    'Guardian',
                    style: theme.textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSecondary,
                      fontSize: 60,
                      shadows: <Shadow>[
                        const Shadow(
                          offset: Offset(1, 1.5),
                          blurRadius: 25.0,
                          color: Color.fromARGB(255, 71, 71, 71),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${localizations.loading.capitalize!}...",
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.colorScheme.onSecondary,
                            shadows: <Shadow>[
                              const Shadow(
                                offset: Offset(1, 1.5),
                                blurRadius: 25.0,
                                color: Color.fromARGB(255, 71, 71, 71),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
