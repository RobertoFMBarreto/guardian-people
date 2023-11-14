import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/operations/user_operations.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/widgets/ui/login/login_form.dart';

/// Class that represents the login page
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    _getToken(context);

    super.initState();
  }

  /// Method that gets the user id and the session token redirecting afterwards to the correct home page
  ///
  /// In case the user id or token are null the user is sent to login
  Future<void> _getToken(BuildContext context) async {
    await getUid(context, autoLogin: false).then(
      (idUser) async {
        if (idUser != null) {
          // get user data
          getUser(idUser).then((user) {
            // if there is stored data use it for getting his role
            if (user != null) {
              Navigator.pushReplacement(
                context,
                CustomPageRouter(page: user.isSuperuser ? '/admin' : '/producer'),
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
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Container(
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
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? gdGradientEnd
                : gdDarkGradientEnd,
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
          ),
          body: const SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: LoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
