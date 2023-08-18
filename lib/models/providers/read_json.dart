import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:guardian/models/alert.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/device_data.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/user.dart';
import 'package:latlong2/latlong.dart';

Future<List<User>> loadUsers() async {
  String usersInput = '';
  usersInput = await rootBundle.loadString('assets/data/users.json');

  Map<String, dynamic> usersMap = await json.decode(usersInput);
  List<User> users = [];
  usersMap['users']!.forEach(
    (user) {
      users.add(
        User(
          uid: user['id'],
          name: user['name'],
          imageUrl: user['imageUrl'],
          email: user['email'],
          password: user['password'],
          role: user['role'],
        ),
      );
    },
  );
  return users;
}

Future<List<User>> loadUsersRole(int role) async {
  String usersInput = await rootBundle.loadString('assets/data/users.json');
  Map<String, dynamic> usersMap = await json.decode(usersInput);
  List<User> users = [];
  usersMap['users']!.forEach(
    (user) {
      if (user['role'] == role) {
        users.add(
          User(
            uid: user['id'],
            name: user['name'],
            imageUrl: user['imageUrl'],
            email: user['email'],
            password: user['password'],
            role: user['role'],
          ),
        );
      }
    },
  );
  return users;
}

Future<List<Device>> loadUserDevices(int uid) async {
  String devicesInput = await rootBundle.loadString('assets/data/devices.json');
  Map devicesMap = await json.decode(devicesInput);
  List<dynamic> devicesMapList = devicesMap['devices'];
  List<Device> devices = [];
  for (var device in devicesMapList) {
    if (device['uid'] == 1) {
      // load device packages
      List<DeviceData> data = [];
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
          state = DeviceDataState.stoped;
        } else {
          state = DeviceDataState.walking;
        }
        data.add(
          DeviceData(
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

      // load devices and their data
      devices.add(
        Device(
          imei: device['imei'],
          color: device['color'],
          isBlocked: device['isBlocked'],
          data: data,
        ),
      );
    }
  }
  return devices;
}

Future<Device?> loadDevice(String deviceImei) async {
  String devicesInput = await rootBundle.loadString('assets/data/devices.json');
  Map devicesMap = await json.decode(devicesInput);
  List<dynamic> devicesMapList = devicesMap['devices'];
  Device device;
  for (var device in devicesMapList) {
    if (device['imei'] == deviceImei) {
      // load device packages
      List<DeviceData> data = [];
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
          state = DeviceDataState.stoped;
        } else {
          state = DeviceDataState.walking;
        }
        data.add(
          DeviceData(
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

      // load device and his data
      device = Device(
        imei: device['imei'],
        color: device['color'],
        isBlocked: device['isBlocked'],
        data: data,
      );
      return device;
    }
  }
  return null;
}

Future<List<Alert>> loadAlerts() async {
  String alertsInput = await rootBundle.loadString('assets/data/alerts.json');
  Map alertsMap = await json.decode(alertsInput);
  List<dynamic> alertsMapList = alertsMap['alerts'];
  List<Alert> alerts = [];
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
    alerts.add(
      Alert(
        device: (await loadDevice(alert['device']))!,
        hasNotification: alert['hasNotification'],
        parameter: parameter,
        comparisson: comparisson,
        value: alert['value'],
      ),
    );
  }
  return alerts;
}

Future<List<Fence>> loadUserFences(int uid) async {
  String devicesInput = await rootBundle.loadString('assets/data/fences.json');
  Map fencesMap = await json.decode(devicesInput);
  List<dynamic> fencesMapList = fencesMap['fences'];
  List<Fence> fences = [];
  for (var fence in fencesMapList) {
    if (fence['uid'] == uid) {
      // load fence points
      List<LatLng> points = [];
      for (var point in fence['points']) {
        points.add(
          LatLng(
            point['lat'],
            point['lon'],
          ),
        );
      }

      // load fences and their points
      fences.add(
        Fence(
          name: fence["name"],
          points: points,
          devices: [],
          color: fence["color"],
        ),
      );
    }
  }
  return fences;
}

Future<List<Fence>> loadDeviceFences(String deviceId) async {
  String devicesInput = await rootBundle.loadString('assets/data/fences.json');
  Map fencesMap = await json.decode(devicesInput);
  List<dynamic> fencesMapList = fencesMap['fences'];
  List<Fence> fences = [];
  for (var fence in fencesMapList) {
    if ((fence['devices'] as List<dynamic>)
        .where((element) => element['imei'] == deviceId)
        .isNotEmpty) {
      // load fence points
      List<LatLng> points = [];
      for (var point in fence['points']) {
        points.add(
          LatLng(
            point['lat'],
            point['lon'],
          ),
        );
      }

      // load fences and their points
      fences.add(
        Fence(
          name: fence["name"],
          points: points,
          devices: [],
          color: fence["color"],
        ),
      );
    }
  }
  return fences;
}
