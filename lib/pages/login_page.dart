import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/widgets/ui/login/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
  });

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
