import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/models/data_models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //   crossAxisCount: 7,
          //   crossAxisSpacing: 0,
          //   mainAxisSpacing: 0,
          //   childAspectRatio: 1.35,
          // ),
          // itemCount: producers.length,
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
