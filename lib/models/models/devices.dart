import 'package:flutter/material.dart';
import 'package:guardian/models/models/device.dart';

class Devices {
  static List<Device> searchDevice(String searchString, List<Device> allDevices) {
    List<Device> result = [];
    if (searchString.isNotEmpty) {
      result = allDevices
          .where(
            (element) => element.imei.toString().contains(searchString),
          )
          .toList();
    } else {
      // reset devices
      // add all devices again
      result.addAll(allDevices);
    }
    return result;
  }

  static List<Device> filterByBatteryLevel(int batMin, int batMax, List<Device> devicesList) {
    List<Device> result = [];
    result = devicesList
        .where(
          (element) => element.battery <= batMax && element.battery >= batMin,
        )
        .toList();
    return result;
  }

  static List<Device> filterByElevation(
      int elevationMin, int elevationMax, List<Device> devicesList) {
    List<Device> result = [];
    result = devicesList
        .where(
          (element) => element.elevation <= elevationMax && element.elevation >= elevationMin,
        )
        .toList();
    return result;
  }

  static List<Device> filterByDataUsage(int dtUsageMin, int dtUsageMax, List<Device> devicesList) {
    List<Device> result = [];
    result = devicesList
        .where(
          (element) => element.dataUsage <= dtUsageMax && element.dataUsage >= dtUsageMin,
        )
        .toList();
    return result;
  }

  static List<Device> filterByTemperature(int tmpMin, int tmpMax, List<Device> devicesList) {
    List<Device> result = [];
    result = devicesList
        .where(
          (element) => element.temperature <= tmpMax && element.temperature >= tmpMin,
        )
        .toList();
    return result;
  }

  static List<Device> filterByAll({
    required RangeValues batteryRangeValues,
    required RangeValues dtUsageRangeValues,
    required RangeValues tmpRangeValues,
    required RangeValues elevationRangeValues,
    required String searchString,
    required List<Device> devicesList,
  }) {
    List<Device> result = [];
    result = filterByBatteryLevel(
      batteryRangeValues.start.round(),
      batteryRangeValues.end.round(),
      devicesList,
    );
    result = filterByDataUsage(
      dtUsageRangeValues.start.round(),
      dtUsageRangeValues.end.round(),
      result,
    );
    result = filterByTemperature(
      tmpRangeValues.start.round(),
      tmpRangeValues.end.round(),
      result,
    );
    result = filterByElevation(
      elevationRangeValues.start.round(),
      elevationRangeValues.end.round(),
      result,
    );
    result = searchDevice(searchString, result);
    return result;
  }
}
