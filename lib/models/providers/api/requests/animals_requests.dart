import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/parsers/animals_parsers.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';

class AnimalRequests {
  /// Method that loads the animals with last location from the api into the [_animals] list
  ///
  /// In case the session token expires then it calls the api to refresh the token and doest the initial request again
  ///
  /// If the server takes too long to answer then the user receives and alert
  static Future<void> getAnimalsFromApiWithLastLocation(
      {required BuildContext context, required Function onDataGotten}) async {
    AnimalProvider.getAnimalsWithLastLocation().then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        await animalsFromJson(response.body);
        onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => getAnimalsFromApiWithLastLocation(
                context: context,
                onDataGotten: onDataGotten,
              ),
            );
          } else if (response.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            setShownNoServerConnection(true).then(
              (_) =>
                  showDialog(context: context, builder: (context) => const ServerErrorDialogue()),
            );
          }
        });
      }
    });
  }

  /// Method that loads all animal data in interval from the API into the [_animals] list
  ///
  /// In case the session token expires then it calls the api to refresh the token and doest the initial request again
  ///
  /// If the server takes too long to answer then the user receives and alert
  static Future<void> getAnimalDataIntervalFromApi({
    required String idAnimal,
    required DateTime startDate,
    required DateTime endDate,
    required BuildContext context,
    required Function onDataGotten,
    required Function onFailed,
  }) async {
    await AnimalProvider.getAnimalData(idAnimal, startDate, endDate).then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        final body = jsonDecode(response.body);

        for (var dt in body) {
          await animalDataFromJson(dt, idAnimal);
        }
        onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => getAnimalDataIntervalFromApi(
                idAnimal: idAnimal,
                startDate: startDate,
                endDate: endDate,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
                context: context,
              ),
            );
          } else if (response.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        onFailed();
      }
    });
  }

  /// Method that allows to call the start realtime stream service
  ///
  /// In case the session token expires then it calls the api to refresh the token and doest the initial request again
  ///
  /// If the server takes too long to answer then the user receives and alert
  static Future<void> startRealtimeStreaming({
    required String idAnimal,
    required BuildContext context,
    required Function onDataGotten,
    required Function onFailed,
  }) async {
    await AnimalProvider.startRealtimeStreaming(idAnimal).then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => startRealtimeStreaming(
                idAnimal: idAnimal,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
                context: context,
              ),
            );
          } else if (response.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        onFailed();
      }
    });
  }

  /// Method that allows to call the stop realtime stream service
  ///
  /// In case the session token expires then it calls the api to refresh the token and doest the initial request again
  ///
  /// If the server takes too long to answer then the user receives and alert
  static Future<void> stopRealtimeStreaming({
    required String idAnimal,
    required BuildContext context,
    required Function onDataGotten,
    required Function onFailed,
  }) async {
    await AnimalProvider.stopRealtimeStreaming(idAnimal).then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => stopRealtimeStreaming(
                idAnimal: idAnimal,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
                context: context,
              ),
            );
          } else if (response.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        onFailed();
      }
    });
  }
}
