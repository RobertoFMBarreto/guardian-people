import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/models/providers/loading_dialog_provider.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/models/providers/session_provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

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
    return Card(
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
                      return 'Campo vazio';
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
                  decoration: const InputDecoration(
                    label: Text('Password'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo vazio';
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
                      // show loading
                      showLoadingDialog(context);

                      // search user and verify if its correct
                      //!TODO: Change to services
                      loadUsers().then(
                        (value) {
                          List<User> users = value;
                          List<User> user = users
                              .where((element) =>
                                  element.email == _email && element.password == _password)
                              .toList();
                          if (user.isEmpty) {
                            Navigator.of(context).pop();
                            setState(() {
                              errorString = 'Email ou password incorretos';
                            });
                          } else {
                            // pop loading dialog
                            Navigator.of(context).pop();
                            // store session data
                            setUserSession(user.first.uid, user.first.role);
                            // store user profile
                            // send to admin or producer
                            switch (user.first.role) {
                              case 0:
                                Navigator.of(context).popAndPushNamed('/admin');
                                break;
                              case 1:
                                Navigator.of(context).popAndPushNamed('/producer');
                                break;
                            }
                          }
                        },
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
