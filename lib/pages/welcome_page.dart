import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
import 'package:guardian/settings/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  bool _firstRun = true;

  @override
  void initState() {
    isSnackbarActive = false;
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
          await getUser(idUser).then((user) async {
            // if there is stored data use it for getting his role
            if (user != null) {
              await _getAlertableSensors().then(
                (_) => Navigator.of(context).pushReplacementNamed(
                  user.isSuperuser ? '/admin' : '/producer',
                ),
              );
            }
          });
        }
      },
    );
  }

  Future<void> _getAlertableSensors() async {
    await AlertRequests.getAlertableSensorsFromApi(
      context: context,
      onDataGotten: (data) async {},
      onFailed: (statusCode) {
        if (!hasConnection && !isSnackbarActive) {
          showNoConnectionSnackBar();
        } else {
          if (statusCode == 507 || statusCode == 404) {
            if (_firstRun == true) {
              showNoConnectionSnackBar();
            }
            _firstRun = false;
          } else if (!isSnackbarActive) {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(localizations.server_error)));
          }
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
                  child: Image.asset('assets/logo/GuardianLogo_white_shadow.png'),
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
                          "${localizations.loading.capitalizeFirst!}...",
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
