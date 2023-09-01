import 'package:flutter/material.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/widgets/pages/login/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromRGBO(88, 200, 160, 1),
              Color.fromRGBO(147, 215, 166, 1),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(147, 215, 166, 1),
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
