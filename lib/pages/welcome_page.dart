import 'package:flutter/material.dart';
import 'package:guardian/db/user_operations.dart';
import 'package:guardian/models/data_models/user.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    getToken(context);

    super.initState();
  }

  Future<void> getToken(BuildContext context) async {
    await getUid(context).then(
      (uid) async {
        if (uid != null) {
          // get user data
          User? user = await getUser(uid);

          //!TODO: To Remove it
          // loadUserDevices(uid);
          // loadUserFences(uid);
          // loadAlerts();

          // if there is stored data use it for getting his role
          if (user != null) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).popAndPushNamed(user.isAdmin ? '/admin' : '/producer');
          } else {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacementNamed('/login');
          }
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color.fromRGBO(88, 200, 160, 1),
            Color.fromRGBO(147, 215, 166, 1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
