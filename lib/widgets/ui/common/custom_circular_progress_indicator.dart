import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

/// Class that represents the custom circular progress indicator
///
/// In case the  progress takes 5 seconds it shows a message warning the for time long time
///
/// In case the progress takes 15 seconds it shows a message warning for the connection to wifi
class CustomCircularProgressIndicator extends StatefulWidget {
  const CustomCircularProgressIndicator({super.key});

  @override
  State<CustomCircularProgressIndicator> createState() => _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState extends State<CustomCircularProgressIndicator> {
  bool _showTakingLong = false;
  bool _showVerifyConnection = false;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 5)).then((value) {
      if (mounted) setState(() => _showTakingLong = true);
    });
    Future.delayed(const Duration(seconds: 15)).then((value) {
      if (mounted) setState(() => _showVerifyConnection = true);
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
          Text('${localizations.loading.capitalizeFirst!}...'),
          if (_showTakingLong) Text('${localizations.longer_than_expected.capitalizeFirst!}!'),
          if (_showVerifyConnection) Text('${localizations.verify_connection.capitalizeFirst!}!')
        ],
      ),
    );
  }
}
