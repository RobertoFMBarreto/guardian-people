import 'package:flutter/material.dart';
import 'package:guardian/pages/producer/web/widget/geofencing.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GeofencingPage extends StatefulWidget {
  final FenceData? fence;
  const GeofencingPage({super.key, this.fence});

  @override
  State<GeofencingPage> createState() => _GeofencingPageState();
}

class _GeofencingPageState extends State<GeofencingPage> {
  // Future<void> _confirmGeofence() async {
  //   BigInt idFence;
  //   // if is edit mode
  //   if (widget.fence != null) {
  //     idFence = widget.fence!.idFence;
  //     // first update the fence
  //     await updateFence(
  //       widget.fence!
  //           .copyWith(
  //             name: _fenceName,
  //             color: HexColor.toHex(color: _fenceColor),
  //           )
  //           .toCompanion(true),
  //     );
  //   } else {
  //     idFence = BigInt.from(Random().nextInt(999999));
  //     await createFence(
  //       FenceCompanion(
  //         idFence: drift.Value(idFence),
  //         name: drift.Value(_fenceName),
  //         color: drift.Value(HexColor.toHex(color: _fenceColor)),
  //       ),
  //     );
  //   }

  //   // second update fence points
  //   createFencePointFromList(_editingPolygon.points, idFence).then(
  //     (value) => Navigator.of(context).pop(_editingPolygon.points),
  //   );
  // }

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
            '${widget.fence != null ? localizations.edit.capitalize() : localizations.add.capitalize()} ${localizations.fence.capitalize()}',
            style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          // actions: [
          //   TextButton(
          //       onPressed: () {},
          //       child: Text(
          //         localizations.confirm.capitalize(),
          //         style: theme.textTheme.bodyMedium!.copyWith(
          //           color: gdSecondaryColor,
          //         ),
          //       ))
          // ],
        ),
        body: Geofencing(
          fence: widget.fence,
        ),
      ),
    );
  }
}
