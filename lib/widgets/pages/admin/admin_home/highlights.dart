import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../producer.dart';

class Highlights extends StatelessWidget {
  final List<User> users;
  const Highlights({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  localizations.highlights.capitalize(),
                  style: theme.textTheme.headlineMedium!.copyWith(fontSize: 42),
                ),
              ),
            Padding(
              padding:
                  kIsWeb ? const EdgeInsets.symmetric(horizontal: 30.0) : const EdgeInsets.all(0),
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: users.length,
                  itemBuilder: (context, index) => Producer(
                    producerName: users[index].name,
                    devicesInfo: '2 ${localizations.devices_alert}',
                    imageUrl: '',
                    uid: users[index].uid,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
