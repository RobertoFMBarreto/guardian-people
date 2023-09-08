import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/user_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/tmp/read_json.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  Future<void> _loadDataRemoveThisLater(List<UserCompanion> users, UserCompanion user) async {
    // TODO: To Remove it
    if (user.isAdmin.value) {
      for (var u in users) {
        await loadUserDevices(u.uid.value);
        await loadUserFences(u.uid.value);
      }
    } else {
      await loadUserDevices(user.uid.value);
      await loadUserFences(user.uid.value);
    }
  }

  void _onLogin(AppLocalizations localizations) {
    // if true the inputs are filled and correct
    if (_formKey.currentState!.validate()) {
      if (hasConnection) {
        // show loading
        showLoadingDialog(context);

        // search user and verify if its correct
        // TODO: Change to services
        loadUsers().then(
          (allUsers) async {
            List<UserCompanion> users = allUsers;
            List<UserCompanion> user = users
                .where((element) => element.email.value == _email && _password == 'teste123@')
                .toList();
            if (user.isEmpty) {
              Navigator.of(context).pop();
              setState(() {
                errorString = localizations.login_error.capitalize();
              });
            } else {
              _loadDataRemoveThisLater(users, user.first).then((_) {
                // pop loading dialog
                Navigator.of(context).pop();
                // store session data
                setUserSession(user.first.uid.value).then((_) {
                  // store user profile
                  createUser(user.first).then((_) {
                    // send to admin or producer
                    Navigator.of(context).popAndPushNamed(
                      user.first.isAdmin.value ? '/admin' : '/producer',
                    );
                  });
                });
              });
            }
          },
        );
      } else {
        setState(() {
          errorString = localizations.no_wifi.capitalize();
        });
      }
    }
  }

  String? _validateEmail(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.empty_field.capitalize();
    }
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.empty_field.capitalize();
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
    );
  }
}
