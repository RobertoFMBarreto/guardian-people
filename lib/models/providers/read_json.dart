import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/device_data.dart';
import 'package:guardian/models/user.dart';

Future<List<User>> loadUsers() async {
  String usersInput = await rootBundle.loadString('assets/data/users.json');
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

Future<List<Device>> loadUserDevices(int uid) async {
  String devicesInput = await rootBundle.loadString('assets/data/devices.json');
  Map devicesMap = await json.decode(devicesInput);
  List<Map> devicesMapList = devicesMap['devices'];
  List<Device> devices = [];
  for (var device in devicesMapList) {
    if (device['uid'] == 1) {
      // load device packages
      List<DeviceData> data = [];
      for (var deviceData in (device['data'] as List<Map>)) {
        data.add(
          DeviceData(
            dataUsage: 7,
            battery: deviceData['battery'],
            elevation: deviceData['altitude'],
            temperature: 24,
            lat: deviceData['lat'],
            lon: deviceData['lon'],
            accuracy: deviceData['accuracy'],
            dateTime: deviceData['lteTime'],
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
