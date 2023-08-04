import 'package:flutter/material.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/pages/login/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late List<User> users;
  @override
  void initState() {
    getUsers();
    super.initState();
  }

  Future<void> getUsers() async {
    loadUsers().then((value) {
      setState(() {
        users = value;
      });
    });
  }

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
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
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
