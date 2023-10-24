import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  static String _getMessageBody(BuildContext context, String data, String channel) {
    final body = jsonDecode(data);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    if (channel == "fencing") {
      return body['fence_is_stay_inside']
          ? '${body['name_animal']} ${localizations.fencing_noti_outside} ${body['fence_name']}'
          : '${body['name_animal']} ${localizations.fencing_noti_inside} ${body['fence_name']}';
    } else if (channel == "alerts") {
      return '';
    }
    return '';
  }

  static Future<void> initInfo(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    //Handle terminated state message clicking
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      if (kDebugMode) {
        print("--------------------Click Background Terminated--------------------");
      }
      final payloadData = jsonDecode(initialMessage.data['body']);
      if (kDebugMode) {
        print("data: $payloadData");
      }
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
      print('Token $token');
    });

    // Open notification with app on background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("--------------------Click Background--------------------");
      }
      try {
        final payloadData = jsonDecode(message.data['body']);
        if (kDebugMode) {
          print("data: $payloadData");
        }
      } catch (e) {}
    });

    FirebaseMessaging.onMessage.listen((message) async {
      if (kDebugMode) {
        print("----------------Message----------------");
      }
      if (kDebugMode) {
        print('Message: ${message.data}');
      }

      final body = jsonDecode(message.data['data']);
      final bodyMessage = _getMessageBody(
          navigatorKey.currentState!.context, message.data['data'], message.data['channel']);
      print("Message: $bodyMessage");
      print("Channel: ${message.data['channel']}");
      // String bodyMessage = "${message.data['title']} ${body['msg']}";

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
        payload: "Teste", //message.data['body'],
      );
    });
  }
}
