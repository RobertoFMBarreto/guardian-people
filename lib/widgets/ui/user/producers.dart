import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/db/drift/query_models/producer_with_devices_amount.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'producer.dart';

class Producers extends StatelessWidget {
  final List<ProducerWithDevicesAmount> producers;
  const Producers({super.key, required this.producers});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return SliverFillRemaining(
      hasScrollBody: true,
      child: Padding(
        padding: kIsWeb ? const EdgeInsets.symmetric(horizontal: 40.0) : const EdgeInsets.all(0),
        child: producers.isEmpty
            ? Center(child: Text(localizations.no_producers.capitalize()))
            : GridView.extent(
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
                          producerName: e.user.name,
                          devicesInfo: '${e.devicesAmount} ${localizations.devices}',
                          imageUrl: '',
                          idUser: e.user.idUser,
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}
