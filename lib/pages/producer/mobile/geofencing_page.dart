import 'package:flutter/material.dart';
import 'package:guardian/widgets/ui/common/geofencing.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the gefencing page for editing and creating a fence
class GeofencingPage extends StatefulWidget {
  final FenceData? fence;
  const GeofencingPage({super.key, this.fence});

  @override
  State<GeofencingPage> createState() => _GeofencingPageState();
}

class _GeofencingPageState extends State<GeofencingPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.fence != null ? localizations.edit.capitalize! : localizations.add.capitalize!} ${localizations.fence.capitalize!}',
            style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: Geofencing(
          fence: widget.fence,
        ),
      ),
    );
  }
}
