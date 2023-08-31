import 'package:flutter/material.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/widgets/pages/login/login_form.dart';

class LoginPage extends StatelessWidget {
  final bool hasConnection;
  const LoginPage({super.key, required this.hasConnection});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Container(
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
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(147, 215, 166, 1),
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
          ),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: LoginForm(hasConnection: hasConnection),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
