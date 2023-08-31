import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/user_operations.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/data_models/user.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/loading_dialog_provider.dart';
import 'package:guardian/models/providers/read_json.dart';
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 10,
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
                      if (value == null || value.isEmpty) {
                        return localizations.empty_field.capitalize();
                      }
                      return null;
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
                      if (value == null || value.isEmpty) {
                        return localizations.empty_field.capitalize();
                      }
                      return null;
                    },
                    onChanged: (newValue) {
                      _password = newValue;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // if true the inputs are filled and correct
                      if (_formKey.currentState!.validate()) {
                        if (hasConnection) {
                          // show loading
                          showLoadingDialog(context);

                          // search user and verify if its correct
                          //!TODO: Change to services
                          loadUsers().then(
                            (allUsers) async {
                              List<User> users = allUsers;
                              List<User> user = users
                                  .where((element) =>
                                      element.email == _email && _password == 'teste123@')
                                  .toList();
                              if (user.isEmpty) {
                                Navigator.of(context).pop();
                                setState(() {
                                  errorString = localizations.login_error.capitalize();
                                });
                              } else {
                                //!TODO: To Remove it
                                if (user.first.isAdmin) {
                                  for (var u in users) {
                                    await createUser(u);
                                    await loadUserDevices(u.uid);
                                    await loadUserFences(u.uid);
                                  }
                                }
                                await loadUserDevices(user.first.uid);
                                await loadUserFences(user.first.uid);
                                //loadAlerts();

                                // pop loading dialog
                                Navigator.of(context).pop();
                                // store session data
                                setUserSession(user.first.uid);
                                // store user profile
                                createUser(user.first).then((_) {
                                  // send to admin or producer
                                  Navigator.of(context).popAndPushNamed(
                                    user.first.isAdmin ? '/admin' : '/producer',
                                  );
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
