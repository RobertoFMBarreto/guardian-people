import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/settings/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FCMMessagingProvider {
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    print('[Messaging] -> Background message ${message.notification!.body}');
  }

  static String getMessageBody(BuildContext context, String data, String channel) {
    final body = jsonDecode(data);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    if (channel == "fencing") {
      return body['fence_is_stay_inside']
          ? localizations.fencing_noti_outside(body['name_animal'], body['fence_name'])
          : localizations.fencing_noti_inside(body['name_animal'], body['fence_name']);
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

  static void _notificationClickHandler(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    if (kDebugMode) {
      print("--------------------Click Background--------------------");
    }
    try {
      final payloadData = jsonDecode(message.data['data']);
      if (message.data['channel'] == 'fencing' || message.data['channel'] == 'alerts') {
        // Receber dados suficientes para construir um animal
        // enviar o animal para a página
        Animal animal = Animal(
          animal: AnimalCompanion(
            animalColor: Value(payloadData['animal']['animal_color']),
            animalIdentification: Value(payloadData['animal']['animal_identification']),
            animalName: Value(payloadData['animal']['animal_name']),
            idAnimal: Value(payloadData['animal']['id_animal']),
            idUser: Value(payloadData['animal']['id_user']),
            isActive: Value(payloadData['animal']['animal_active']),
          ),
          data: [],
        );
        navigatorKey.currentState!.pushNamed('/producer/device', arguments: {"animal": animal});
      }
      if (kDebugMode) {}
    } catch (e) {}
  }

  static void _onMessage(
    RemoteMessage message,
  ) {}

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
      //final payloadData = jsonDecode(initialMessage.data['body']);
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

            print("data: $payloadData");
          } else {}
        } catch (e) {}
        return;
      },
    );

    FirebaseMessaging.instance.getToken().then((String? token) {
      assert(token != null);
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

      final body = jsonDecode(message.data['data']);
      final bodyMessage = getMessageBody(
          navigatorKey.currentState!.context, message.data['data'], message.data['channel']);

      DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
      );

      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'Guardian',
        'Guardian',
        groupKey: 'com.example.guardian',
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
        body['name_animal'], //message.data['title'],
        bodyMessage,
        platformChannelSpecifics,
        payload: message.data.toString(), //message.data['body'],
      );
    });
  }
}
