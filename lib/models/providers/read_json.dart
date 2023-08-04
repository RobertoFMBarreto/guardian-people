import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:guardian/models/models/device.dart';
import 'package:guardian/models/models/device_data.dart';
import 'package:guardian/models/models/devices.dart';

Future readJsonFile() async {
  String usersInput = await rootBundle.loadString('assets/data/users.json');
  String devicesInput = await rootBundle.loadString('assets/data/devices.json');
  Map usersMap = await json.decode(usersInput);
  Map devicesMap = await json.decode(devicesInput);
  print(usersMap['users']);
  print(devicesMap['devices']);
}

Future<Map> loadUsers() async {
  String usersInput = await rootBundle.loadString('assets/data/users.json');
  Map usersMap = await json.decode(usersInput);
  print(usersMap['users']);
  return usersMap;
}

Future<Map> loadUserDevices(int uid) async {
  String devicesInput = await rootBundle.loadString('assets/data/devices.json');
  Map devicesMap = await json.decode(devicesInput);
  List<Map> devicesMapList = devicesMap['devices'];
  List<Device> devices = [];
  devicesMapList.forEach(
    (device) {
      if (device['uid'] == 1) {
        // load device packages
        List<DeviceData> data = [];
        (device['data'] as List<Map>).forEach(
          (deviceData) {
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
          },
        );

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
    },
  );
  print(devices);
  return devicesMap;
}
