import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

/// Class that represents the server error dialogue
class ServerErrorDialogue extends StatelessWidget {
  const ServerErrorDialogue({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.server_error.capitalizeFirst!),
      content: Text(
        localizations.server_error_body.capitalizeFirst!,
      ),
    );
  }
}
