import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/providers/api/requests/auth_requests.dart';
import 'package:guardian/settings/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the fcm messaging provider
class FCMMessagingProvider {
  /// Method that handles a background message
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    if (kDebugMode) {
      print('[Messaging] -> Background message ${message.notification!.body}');
    }
  }

  /// Method that allows to get a message body
  static String getMessageBody(BuildContext context, String data, String channel) {
    final body = jsonDecode(data);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    if (channel == "fencing") {
      return body['fence_is_stay_inside']
          ? localizations.fencing_noti_outside(body['animal']['animal_name'], body['fence_name'])
          : localizations.fencing_noti_inside(body['animal']['animal_name'], body['fence_name']);
    } else if (channel == "alerts") {
      final currentValue = double.parse(body['sensor_data']);
      final animalName = body['animal']['animal_name'];
      final sensorName = body['alert']['sensor_name'];
      if (sensorName == "Altitude") {
        return localizations.notification_alert_altitude_body_string(animalName, currentValue);
      } else if (sensorName == "Battery") {
        return localizations.notification_alert_battery_body_string(animalName, currentValue);
      } else if (sensorName == "Skin Temperature") {
        return localizations.notification_alert_temperature_body_string(animalName, currentValue);
      }
    }
    return '';
  }

  /// Method that handles a notification click
  static Future<void> _notificationClickHandler(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    if (kDebugMode) {
      print("--------------------Click Background--------------------");
      print(message.data);
    }
    try {
      final payloadData = jsonDecode(message.data['data']);
      if (message.data['channel'] == 'fencing' || message.data['channel'] == 'alerts') {
        List<String> states = ['Ruminar', 'Comer', 'Andar', 'Correr', 'Parada'];

        // Receber dados suficientes para construir um animal
        final animal = AnimalCompanion(
          animalColor: Value(payloadData['animal']['animal_color']),
          animalIdentification: Value(payloadData['animal']['animal_identification']),
          animalName: Value(payloadData['animal']['animal_name']),
          idAnimal: Value(payloadData['animal']['id_animal']),
          idUser: Value(payloadData['animal']['id_user']),
          isActive: Value(payloadData['animal']['animal_active']),
        );
        final location = AnimalLocationsCompanion(
          accuracy: Value(double.tryParse(payloadData['animal']['locationData']['accuracy'])),
          animalDataId: Value(payloadData['animal']['locationData']['id_data']),
          battery: Value(int.parse(payloadData['animal']['locationData']['battery'])),
          date: Value(DateTime.parse(payloadData['animal']['locationData']['date'])),
          elevation: Value(double.tryParse(payloadData['animal']['locationData']['altitude'])),
          idAnimal: Value(payloadData['animal']['id_animal']),
          lat: Value(double.tryParse(payloadData['animal']['locationData']['lat'])),
          lon: Value(double.tryParse(payloadData['animal']['locationData']['lon'])),
          state: Value(states[Random().nextInt(states.length)]),
          temperature:
              Value(double.tryParse(payloadData['animal']['locationData']['skintemperature'])),
        );
        await createAnimal(animal);
        await createAnimalData(location);
        // enviar o animal para a página
        navigatorKey.currentState!.pushNamed('/producer/device', arguments: {
          "animal": Animal(
            animal: animal,
            data: [location],
          )
        });
      }
      if (kDebugMode) {}
      // ignore: empty_catches
    } catch (e) {}
  }

  /// Method tat starts the fcm messaging
  static Future<void> initInfo(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    await FirebaseMessaging.instance.setDeliveryMetricsExportToBigQuery(true);
    //Handle terminated state message clicking
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print("--------------------Click Background Terminated--------------------");
        _notificationClickHandler(initialMessage, navigatorKey);
      }
      if (kDebugMode) {}
    }
    const androidInitialize = AndroidInitializationSettings('icon_512');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: initializationSettingsDarwin);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // when the app is in foreground
      onDidReceiveNotificationResponse: (details) {
        try {
          final payload = details.payload;
          if (payload != null && payload.isNotEmpty) {
            final payloadData = jsonDecode(payload);

            if (kDebugMode) {
              print("data: $payloadData");
            }
          } else {}
          // ignore: empty_catches
        } catch (e) {}
        return;
      },
    );

    FirebaseMessaging.instance.getToken().then((String? token) {
      assert(token != null);
      AuthRequests.refreshDevicetoken(
        context: navigatorKey.currentContext!,
        devicetoken: token ?? '',
        onFailGoLogin: false,
        onDataGotten: () {
          if (kDebugMode) {
            print(token);
          }
        },
      );
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      if (kDebugMode) {
        print(
            'New Token: $token | ${ModalRoute.of(navigatorKey.currentState!.context)!.settings.name}');
      }
      AuthRequests.refreshDevicetoken(
        context: navigatorKey.currentContext!,
        devicetoken: token,
        onDataGotten: () {},
      );
    });

    // Open notification with app on background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _notificationClickHandler(message, navigatorKey);
    });

    FirebaseMessaging.onMessage.listen((message) async {
      if (kDebugMode) {
        print("----------------Message----------------");
      }
      if (kDebugMode) {
        print('Message: ${message.data}');
      }

      final bodyMessage = getMessageBody(
          navigatorKey.currentState!.context, message.data['data'], message.data['channel']);

      DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
      );

      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'Guardian',
        'Guardian',
        groupKey: 'com.linovt.Guardian',
        importance: Importance.high,
        // styleInformation: bigTextStyleInformation,
        styleInformation: const DefaultStyleInformation(true, true),
        color: gdSecondaryColor,
        colorized: true,
        priority: Priority.high,
        playSound: true,
        icon: const AndroidInitializationSettings('app_icon').defaultIcon,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        message.data['title'], //message.data['title'],
        bodyMessage,
        platformChannelSpecifics,
        payload: message.data['body'], //message.data['body'],
      );
    });
  }
}
