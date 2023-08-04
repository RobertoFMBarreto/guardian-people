import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return const Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The loading indicator
              CircularProgressIndicator(color: gdSecondaryColor),
              SizedBox(
                height: 15,
              ),
              // Some text
              Text('A Realizar login...')
            ],
          ),
        ),
      );
    },
  );
}
