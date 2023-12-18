import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:guardian/models/helpers/cookies/cookies_stub.dart'
    if (dart.library.io) 'package:guardian/models/helpers/cookies/cookies_mobile.dart'
    if (dart.library.js) 'package:guardian/models/helpers/cookies/cookies_web.dart'
    as cookies_helper;
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/api/requests/auth_requests.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/user_operations.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';

/// Class that represents and manages the login form
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String errorString = '';
  String _email = '';
  String _password = '';

  /// Method that validates all form fields and the does the authentication logic
  ///
  /// 1. set user sessions
  /// 2. create user data
  /// 3. send user to correct screen
  void _onLogin(AppLocalizations localizations) {
    // if true the inputs are filled and correct
    if (_formKey.currentState!.validate()) {
      if (hasConnection) {
        // show loading
        showLoadingDialog(context);

        // search user and verify if its correct

        AuthProvider.login(_email, _password).then((resp) {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final body = jsonDecode(resp.body);
            String refreshToken;
            if (kIsWeb) {
              refreshToken = cookies_helper.getRefreshCookie(http.Response('', 200));
            } else {
              refreshToken = cookies_helper.getRefreshCookie(resp);
            }

            if (!kIsWeb) {
              FirebaseMessaging.instance.getToken().then((token) {
                if (token != null) {
                  AuthRequests.refreshDevicetoken(
                    context: context,
                    devicetoken: token,
                    onDataGotten: () {
                      if (kDebugMode) {
                        print(token);
                      }
                    },
                  );
                }
              });
            }

            setUserSession(body['uid'], body['token'], refreshToken).then((_) {
              // store user profile
              createUser(
                UserCompanion(
                  idUser: drift.Value(body['uid']),
                  email: drift.Value(body['email']),
                  name: drift.Value(body['name']),
                  phone: drift.Value(int.parse(body['phone'])),
                  isProducer: drift.Value(body['isProducer'] == true),
                  isSuperuser: drift.Value(body['isSuperuser'] == true),
                  isOverViewer: drift.Value(body['isOverviewer'] == true),
                ),
              ).then((_) {
                // send to admin or producer
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context)
                    .pushReplacementNamed(body['isProducer'] == false ? '/admin' : '/producer');
              });
            });
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
          } else {
            setState(() {
              final body = jsonDecode(resp.body) as Map<String, dynamic>;
              if (body.containsKey('Error')) {
                if (body["Error"] == "wrong_email_or_password") {
                  errorString = localizations.email_password_wrong.capitalizeFirst!;
                } else {
                  errorString = localizations.server_error.capitalizeFirst!;
                }
              } else {
                errorString = localizations.server_error.capitalizeFirst!;
              }
            });
            Navigator.pop(context);
          }
        });
      } else {
        setState(() {
          errorString = localizations.no_wifi.capitalizeFirst!;
        });
      }
    }
  }

  /// Method that implements the email validation logic
  String? _validateEmail(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.empty_field.capitalizeFirst!;
    }
    return null;
  }

  /// Method that implements the password validation logic
  String? _validatePassword(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.empty_field.capitalizeFirst!;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return kIsWeb || isBigScreen
        ? Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(
                          flex: 2, child: Image.asset('assets/logo/GuardianLogo_white_shadow.png')),
                      const Expanded(child: SizedBox()),
                    ],
                  )),
              Expanded(
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                    color: theme.colorScheme.background,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Form(
                              key: _formKey,
                              child: Center(
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                                        child: Text(
                                          'Login',
                                          style: theme.textTheme.headlineMedium,
                                        ),
                                      ),
                                      errorString.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: gdAltErrorColor,
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    errorString,
                                                    style: theme.textTheme.bodyMedium!.copyWith(
                                                      color: gdOnErrorColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            label: Text('Email'),
                                          ),
                                          validator: (value) {
                                            return _validateEmail(value, localizations);
                                          },
                                          onChanged: (newValue) {
                                            _email = newValue;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                          obscureText: true,
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          decoration: const InputDecoration(
                                            label: Text('Password'),
                                          ),
                                          validator: (value) {
                                            return _validatePassword(value, localizations);
                                          },
                                          onChanged: (newValue) {
                                            _password = newValue;
                                          },
                                          onFieldSubmitted: (text) {
                                            _onLogin(localizations);
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            _onLogin(localizations);
                                          },
                                          child: const Text('Login'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 10,
                color: theme.colorScheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Image.asset('assets/logo/GuardianLogo_white_shadow.png',
                                width: 300),
                            // Text(
                            //   'Guardian',
                            //   style: theme.textTheme.headlineMedium,
                            // ),
                          ),
                          errorString.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: gdAltErrorColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        errorString,
                                        style: theme.textTheme.bodyMedium!.copyWith(
                                          color: gdOnErrorColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Email'),
                              ),
                              validator: (value) {
                                return _validateEmail(value, localizations);
                              },
                              onChanged: (newValue) {
                                _email = newValue;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                label: Text('Password'),
                              ),
                              validator: (value) {
                                return _validatePassword(value, localizations);
                              },
                              onChanged: (newValue) {
                                _password = newValue;
                              },
                              onFieldSubmitted: (text) {
                                _onLogin(localizations);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                _onLogin(localizations);
                              },
                              child: const Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
