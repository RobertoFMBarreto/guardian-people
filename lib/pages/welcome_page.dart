import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/db/drift/operations/user_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/session_provider.dart';

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

  Future<void> _getToken(BuildContext context) async {
    await getUid(context).then(
      (uid) async {
        if (uid != null) {
          // get user data
          getUser(uid).then((user) {
            // TODO: To Remove it
            // loadUserDevices(uid);
            // loadUserFences(uid);
            // loadAlerts();

            // if there is stored data use it for getting his role
            if (user != null) {
              Navigator.of(context).popAndPushNamed(user.isAdmin ? '/admin' : '/producer');
            } else {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          });
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
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
                          "${localizations.loading.capitalize()}...",
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
