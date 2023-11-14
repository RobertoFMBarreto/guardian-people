import 'dart:convert';

import 'package:drift/drift.dart' as drift;
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
          print(resp.headers);
          print(resp.statusCode);
          print(resp.body);
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final body = jsonDecode(resp.body);
            String refreshToken = resp.headers['set-cookie']!.split('=')[1].split(';')[0];
            setUserSession(body['uid'], body['token'], refreshToken).then((_) {
              // store user profile
              createUser(UserCompanion(
                      idUser: drift.Value(body['uid']),
                      email: drift.Value(body['email']),
                      name: drift.Value(body['name']),
                      phone: drift.Value(int.parse(body['phone'])),
                      isProducer: drift.Value(body['isProducer'] == true),
                      isSuperuser: drift.Value(body['isSuperuser'] == true),
                      isOverViewer: drift.Value(body['isOverviewer'] == true)))
                  .then((_) {
                // send to admin or producer
                Navigator.of(context).popAndPushNamed(
                  body['isProducer'] == false ? '/admin' : '/producer',
                );
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
              errorString = resp.body;
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
    return Container(
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
                    child: Text(
                      'Guardian',
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
    );
  }
}
