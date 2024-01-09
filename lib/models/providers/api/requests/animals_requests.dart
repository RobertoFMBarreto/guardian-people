import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/parsers/animals_parsers.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';

/// Class that represents the animal requests
class AnimalRequests {
  /// Method that loads the animals with last data from the API into the [_animals] list
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> getAnimalsFromApiWithLastData(
      {required BuildContext context,
      required Function onDataGotten,
      required Function(int) onFailed}) async {
    await AnimalProvider.getAnimals().then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);

        // Delete all animals
        await deleteAllAnimals().then((_) async {
          // Delete animals last location
          await animalsFromJson(
            response.body,
          );
        });

        onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => getAnimalsFromApiWithLastLocation(
                context: context,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
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
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that loads the animals with last location from the API into the [_animals] list
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> getAnimalsFromApiWithLastLocation(
      {required BuildContext context,
      required Function onDataGotten,
      required Function(int) onFailed}) async {
    await AnimalProvider.getAnimalsWithLastLocation().then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);

        // Delete all animals
        await deleteAllAnimals().then((_) async {
          // Delete animals last location
          await animalsFromJson(
            response.body,
            showLog: true,
          );
        });

        onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => getAnimalsFromApiWithLastLocation(
                context: context,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
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
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that loads all animal data in interval from the API into the [_animals] list
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> getAnimalDataIntervalFromApi({
    required String idAnimal,
    required DateTime startDate,
    required DateTime endDate,
    required BuildContext context,
    required Function onDataGotten,
    required Function(int) onFailed,
  }) async {
    await AnimalProvider.getAnimalData(idAnimal, startDate, endDate).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        final body = jsonDecode(response.body);

        await deleteAnimalDataInInterval(
          idAnimal: idAnimal,
          startDate: startDate,
          endDate: endDate,
          isInterval: true,
        ).then((_) async {
          for (var dt in body) {
            await animalDataFromJson(dt, idAnimal);
          }
        });

        await onDataGotten();
      } else if (response.statusCode == 401) {
        await AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
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
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
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
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that loads all animal activity in interval from the API into the [_animals] list
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> getAnimalActivityIntervalFromApi({
    required String idAnimal,
    required DateTime startDate,
    required DateTime endDate,
    required BuildContext context,
    required Function onDataGotten,
    required Function(int) onFailed,
  }) async {
    await AnimalProvider.getAnimalActivity(idAnimal, startDate, endDate).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        final body = jsonDecode(response.body);

        // await deleteAnimalDataInInterval(
        //   idAnimal: idAnimal,
        //   startDate: startDate,
        //   endDate: endDate,
        //   isInterval: true,
        // ).then((_) async {
        //   for (var dt in body) {
        //     await animalDataFromJson(dt, idAnimal);
        //   }
        // });
        for (var dt in body) {
          await animalActivityFromJson(dt, idAnimal);
        }

        await onDataGotten();
      } else if (response.statusCode == 401) {
        await AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => getAnimalActivityIntervalFromApi(
                idAnimal: idAnimal,
                startDate: startDate,
                endDate: endDate,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
                context: context,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
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
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that allows to call the start realtime stream service
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> startRealtimeStreaming({
    required String idAnimal,
    required BuildContext context,
    required Function onDataGotten,
    required Function(int) onFailed,
  }) async {
    await AnimalProvider.startRealtimeStreaming(idAnimal).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
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
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
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
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that allows to call the stop realtime stream service
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> stopRealtimeStreaming({
    required String idAnimal,
    required BuildContext context,
    required Function onDataGotten,
    required Function(int) onFailed,
  }) async {
    await AnimalProvider.stopRealtimeStreaming(idAnimal).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
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
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
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
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that allows to update an animal in the API
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> updateAnimal({
    required Animal animal,
    required BuildContext context,
    required Function(int) onFailed,
    required Function onDataGotten,
  }) async {
    await AnimalProvider.updateAnimal(animal.animal).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        await onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => updateAnimal(
                animal: animal,
                onFailed: onFailed,
                context: context,
                onDataGotten: onDataGotten,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
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
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }
}
