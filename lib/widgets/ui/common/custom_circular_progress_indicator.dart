import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';

class CustomCircularProgressIndicator extends StatefulWidget {
  const CustomCircularProgressIndicator({super.key});

  @override
  State<CustomCircularProgressIndicator> createState() => _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState extends State<CustomCircularProgressIndicator> {
  bool showTakingLong = false;
  bool showVerifyConnection = false;
  @override
  void initState() {
    Future.delayed(Duration(seconds: 5)).then((value) {
      if (mounted) setState(() => showTakingLong = true);
    });
    Future.delayed(Duration(seconds: 15)).then((value) {
      if (mounted) setState(() => showVerifyConnection = true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.secondary,
          ),
          Text('${localizations.loading.capitalize()}...'),
          if (showTakingLong) Text('${localizations.longer_than_expected.capitalize()}!'),
          if (showVerifyConnection) Text('${localizations.verify_connection.capitalize()}!')
        ],
      ),
    );
  }
}
