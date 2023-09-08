import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/device_data_operations.dart';
import 'package:guardian/models/db/drift/operations/device_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/models/db/drift/tables/Alerts/user_alert.dart';
import 'package:guardian/models/providers/tmp/alerts_data.dart';
import 'package:guardian/models/providers/tmp/devices_data.dart';
import 'package:guardian/models/providers/tmp/fences_data.dart';
import 'package:guardian/models/providers/tmp/users_data.dart';

Future<List<UserCompanion>> loadUsers() async {
  String usersInput = '';
  if (!kIsWeb) {
    usersInput = await rootBundle.loadString('assets/data/users.json');
  }

  Map<String, dynamic> usersMap = {};
  if (!kIsWeb) {
    usersMap = await json.decode(usersInput);
  } else {
    usersMap = usersDataJson;
  }
  List<UserCompanion> users = [];
  usersMap['users']!.forEach(
    (user) {
      users.add(
        UserCompanion(
          uid: Value(user['id']),
          name: Value(user['name']),
          email: Value(user['email']),
          isAdmin: Value(user['role'] == 0),
          phone: const Value(999999999),
        ),
      );
    },
  );
  return users;
}

Future<List<DeviceCompanion>> loadUserDevices(String uid) async {
  String devicesInput = '';
  if (!kIsWeb) {
    devicesInput = await rootBundle.loadString('assets/data/devices.json');
  }
  Map devicesMap = {};
  if (!kIsWeb) {
    devicesMap = await json.decode(devicesInput);
  } else {
    devicesMap = devicesDataJson;
  }
  List<dynamic> devicesMapList = devicesMap['devices'];
  List<DeviceCompanion> devices = [];
  for (var device in devicesMapList) {
    if (device['uid'] == uid) {
      print('GdDebug> Device:$device');
      // load devices and their data
      await createDevice(
        DeviceCompanion(
          imei: Value(device['imei']),
          color: Value(device['color']),
          isActive: Value(device['isBlocked']),
          deviceId: Value(device['imei']),
          name: Value(device['name']),
          uid: Value(device['uid']),
        ),
      );
      // load device packages
      for (var deviceData in device['data']) {
        await createDeviceData(
          DeviceLocationsCompanion(
            deviceDataId: Value(deviceData['id']),
            deviceId: Value(device['imei']),
            dataUsage: const Value(7),
            battery: Value(deviceData['battery']),
            elevation: Value(deviceData['altitude']),
            temperature: const Value(24),
            lat: Value(deviceData['lat']),
            lon: Value(deviceData['lon']),
            accuracy: Value(deviceData['accuracy']),
            date: Value(DateTime.parse(deviceData['lteTime'])),
            state: Value(deviceData['state']),
          ),
        );
      }
    }
  }
  return devices;
}

Future<List<UserAlert>> loadAlerts() async {
  String alertsInput = '';
  if (!kIsWeb) {
    alertsInput = await rootBundle.loadString('assets/data/alerts.json');
  }
  Map alertsMap;
  if (!kIsWeb) {
    alertsMap = await json.decode(alertsInput);
  } else {
    alertsMap = alertsDataJson;
  }
  List<dynamic> alertsMapList = alertsMap['alerts'];
  List<UserAlert> alerts = [];
  for (var alert in alertsMapList) {
    createAlert(
      UserAlertCompanion(
        hasNotification: Value(alert['hasNotification']),
        parameter: Value(alert['parameter']),
        comparisson: Value(alert['comparisson']),
        value: Value(alert['value']),
        alertId: Value(alert['id']),
      ),
    );
  }
  return alerts;
}

Future<void> loadUserFences(String uid) async {
  String fencesInput = '';
  if (!kIsWeb) {
    fencesInput = await rootBundle.loadString('assets/data/fences.json');
  }
  Map fencesMap;
  if (!kIsWeb) {
    fencesMap = await json.decode(fencesInput);
  } else {
    fencesMap = fencesDataJson;
  }
  List<dynamic> fencesMapList = fencesMap['fences'];
  for (var fence in fencesMapList) {
    if (fence['uid'] == uid) {
      // load fence points
      for (var point in fence['points']) {
        createFencePoint(
          FencePointsCompanion(
            fenceId: Value(fence["id"]),
            lat: Value(point['lat']),
            lon: Value(point['lon']),
          ),
        );
      }

      for (var device in fence['devices']) {
        createFenceDevice(
          FenceDevicesCompanion(
            fenceId: Value(fence["id"]),
            deviceId: Value(device['imei']),
          ),
        );
      }

      // load fences and their points
      createFence(
        FenceCompanion(
          name: Value(fence["name"]),
          color: Value(fence["color"]),
          fenceId: Value(fence["id"]),
        ),
      );
    }
  }
}

// Future<Device?> loadDevice(String deviceImei) async {
//   String devicesInput = await rootBundle.loadString('assets/data/devices.json');
//   Map devicesMap = await json.decode(devicesInput);
//   List<dynamic> devicesMapList = devicesMap['devices'];
//   for (var device in devicesMapList) {
//     if (device['imei'] == deviceImei) {
//       // load device packages
//       List<DeviceData> data = [];
//       for (var deviceData in device['data']) {
//         DeviceDataState state;
//         if (deviceData['state'] == '=') {
//           state = DeviceDataState.eating;
//         } else if (deviceData['state'] == 'fighting') {
//           state = DeviceDataState.fighting;
//         } else if (deviceData['state'] == 'ruminating') {
//           state = DeviceDataState.ruminating;
//         } else if (deviceData['state'] == 'running') {
//           state = DeviceDataState.running;
//         } else if (deviceData['state'] == 'stopped') {
//           state = DeviceDataState.stoped;
//         } else {
//           state = DeviceDataState.walking;
//         }
//         data.add(
//           DeviceData(
//             deviceId: device['imei'],
//             dataUsage: 7,
//             battery: deviceData['battery'],
//             elevation: deviceData['altitude'],
//             temperature: 24,
//             lat: deviceData['lat'],
//             lon: deviceData['lon'],
//             accuracy: deviceData['accuracy'],
//             dateTime: DateTime.parse(deviceData['lteTime']),
//             state: state,
//           ),
//         );
//       }

//       // load device and his data
//       return Device(
//         imei: device['imei'],
//         color: device['color'],
//         isActive: device['isBlocked'],
//         deviceId: device['imei'],
//         name: device['name'],
//         uid: device['uid'],
//       );
//     }
//   }
//   return null;
// }

// Future<List<User>> loadUsersRole(int role) async {
//   String usersInput = await rootBundle.loadString('assets/data/users.json');
//   Map<String, dynamic> usersMap = await json.decode(usersInput);
//   List<User> users = [];
//   usersMap['users']!.forEach(
//     (user) {
//       if (user['role'] == role) {
//         users.add(
//           User(
//             uid: user['id'],
//             name: user['name'],
//             imageUrl: user['imageUrl'],
//             email: user['email'],
//             password: user['password'],
//             role: user['role'],
//           ),
//         );
//       }
//     },
//   );
//   return users;
// }

// Future<List<Fence>> loadDeviceFences(String deviceId) async {
//   String devicesInput = await rootBundle.loadString('assets/data/fences.json');
//   Map fencesMap = await json.decode(devicesInput);
//   List<dynamic> fencesMapList = fencesMap['fences'];
//   List<Fence> fences = [];
//   for (var fence in fencesMapList) {
//     if ((fence['devices'] as List<dynamic>)
//         .where((element) => element['imei'] == deviceId)
//         .isNotEmpty) {
//       // load fence points
//       List<LatLng> points = [];
//       for (var point in fence['points']) {
//         points.add(
//           LatLng(
//             point['lat'],
//             point['lon'],
//           ),
//         );
//       }

//       // load fences and their points
//       fences.add(
//         Fence(
//           name: fence["name"],
//           color: fence["color"],
//           fenceId: fence["id"],
//         ),
//       );
//     }
//   }
//   return fences;
// }
