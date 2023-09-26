import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';

class ServerErrorDialogue extends StatelessWidget {
  const ServerErrorDialogue({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.server_error.capitalize()),
      content: Text(
        localizations.server_error_body.capitalize(),
      ),
    );
  }
}
