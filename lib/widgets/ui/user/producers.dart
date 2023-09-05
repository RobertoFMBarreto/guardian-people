import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/db/data_models/user.dart';
import 'producer.dart';

class Producers extends StatelessWidget {
  final List<User> producers;
  const Producers({super.key, required this.producers});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return SliverFillRemaining(
      hasScrollBody: true,
      child: Padding(
        padding: kIsWeb ? const EdgeInsets.symmetric(horizontal: 40.0) : const EdgeInsets.all(0),
        child: GridView.extent(
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1,
          maxCrossAxisExtent: 200,
          children: producers
              .map(
                (e) => Container(
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 200,
                    minHeight: 150,
                    maxHeight: 150,
                  ),
                  child: Producer(
                    producerName: e.name,
                    devicesInfo: '${e.devicesAmount} ${localizations.devices}',
                    imageUrl: '',
                    uid: e.uid,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
