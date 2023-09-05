import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:guardian/models/db/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/Device/device_data.dart';
import 'package:guardian/models/db/data_models/Fences/fence.dart';
import 'package:guardian/models/db/data_models/Fences/fence_devices.dart';
import 'package:guardian/models/db/data_models/Fences/fence_points.dart';
import 'package:guardian/models/db/data_models/user.dart';
import 'package:guardian/models/db/operations/device_operations.dart';
import 'package:guardian/models/db/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/operations/fence_operations.dart';
import 'package:guardian/models/db/operations/device_data_operations.dart';
import 'package:guardian/models/db/operations/fence_points_operations.dart';
import 'package:guardian/models/db/operations/user_alert_operations.dart';
import 'package:guardian/models/providers/tmp/alerts_data.dart';
import 'package:guardian/models/providers/tmp/devices_data.dart';
import 'package:guardian/models/providers/tmp/fences_data.dart';
import 'package:guardian/models/providers/tmp/users_data.dart';

Future<List<User>> loadUsers() async {
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
  List<User> users = [];
  usersMap['users']!.forEach(
    (user) {
      users.add(
        User(
          uid: user['id'],
          name: user['name'],
          email: user['email'],
          isAdmin: user['role'] == 0,
          phone: 999999999,
        ),
      );
    },
  );
  return users;
}

Future<List<Device>> loadUserDevices(String uid) async {
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
  List<Device> devices = [];
  for (var device in devicesMapList) {
    if (device['uid'] == uid) {
      // load devices and their data
      await createDevice(
        Device(
          imei: device['imei'],
          color: device['color'],
          isActive: device['isBlocked'],
          deviceId: device['imei'],
          name: device['name'],
          uid: device['uid'],
        ),
      );
      // load device packages
      for (var deviceData in device['data']) {
        DeviceDataState state;
        if (deviceData['state'] == '=') {
          state = DeviceDataState.eating;
        } else if (deviceData['state'] == 'fighting') {
          state = DeviceDataState.fighting;
        } else if (deviceData['state'] == 'ruminating') {
          state = DeviceDataState.ruminating;
        } else if (deviceData['state'] == 'running') {
          state = DeviceDataState.running;
        } else if (deviceData['state'] == 'stopped') {
          state = DeviceDataState.stopped;
        } else {
          state = DeviceDataState.walking;
        }
        await createDeviceData(
          DeviceData(
            deviceId: device['imei'],
            dataUsage: 7,
            battery: deviceData['battery'],
            elevation: deviceData['altitude'],
            temperature: 24,
            lat: deviceData['lat'],
            lon: deviceData['lon'],
            accuracy: deviceData['accuracy'],
            dateTime: DateTime.parse(deviceData['lteTime']),
            state: state,
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
    // load alerts
    AlertParameter parameter;
    if (alert['parameter'] == 'tmp') {
      parameter = AlertParameter.temperature;
    } else if (alert['parameter'] == 'bat') {
      parameter = AlertParameter.battery;
    } else {
      parameter = AlertParameter.dataUsage;
    }
    AlertComparissons comparisson;
    if (alert['parameter'] == '=') {
      comparisson = AlertComparissons.equal;
    } else if (alert['parameter'] == '>') {
      comparisson = AlertComparissons.greater;
    } else if (alert['parameter'] == '<') {
      comparisson = AlertComparissons.less;
    } else if (alert['parameter'] == '>=') {
      comparisson = AlertComparissons.greaterOrEqual;
    } else {
      comparisson = AlertComparissons.lessOrEqual;
    }

    createAlert(
      UserAlert(
        hasNotification: alert['hasNotification'],
        parameter: parameter,
        comparisson: comparisson,
        value: alert['value'],
        alertId: alert['id'],
      ),
    );
  }
  return alerts;
}

Future<List<Fence>> loadUserFences(String uid) async {
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
  List<Fence> fences = [];
  for (var fence in fencesMapList) {
    if (fence['uid'] == uid) {
      // load fence points
      for (var point in fence['points']) {
        createFencePoint(
          FencePoint(
            fenceId: fence["id"],
            lat: point['lat'],
            lon: point['lon'],
          ),
        );
      }

      for (var device in fence['devices']) {
        createFenceDevice(
          FenceDevice(
            fenceId: fence["id"],
            deviceId: device['imei'],
          ),
        );
      }

      // load fences and their points
      createFence(
        Fence(
          name: fence["name"],
          color: fence["color"],
          fenceId: fence["id"],
        ),
      );
    }
  }
  return fences;
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
