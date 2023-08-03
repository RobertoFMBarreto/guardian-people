import 'package:flutter/material.dart';

class DeviceWidgetProvider {
  /*
  Method for getting the device battery indicator icon
  @param int deviceBattery -> actual device battery
  @param Color color -> icon color
  @returns Battery icon
  */
  static Widget getBatteryWidget({
    required int deviceBattery,
    required Color color,
  }) {
    Widget icon;

    if (deviceBattery == 100) {
      icon = Icon(
        Icons.battery_full,
        color: color,
      );
    } else if (deviceBattery <= 99 && deviceBattery > 85) {
      icon = Icon(
        Icons.battery_6_bar,
        color: color,
      );
    } else if (deviceBattery <= 85 && deviceBattery > 50) {
      icon = Icon(
        Icons.battery_5_bar,
        color: color,
      );
    } else if (deviceBattery <= 50 && deviceBattery > 25) {
      icon = Icon(
        Icons.battery_4_bar,
        color: color,
      );
    } else if (deviceBattery <= 25 && deviceBattery > 10) {
      icon = Icon(
        Icons.battery_3_bar,
        color: color,
      );
    } else if (deviceBattery <= 10 && deviceBattery > 5) {
      icon = Icon(
        Icons.battery_2_bar,
        color: color,
      );
    } else if (deviceBattery <= 5 && deviceBattery > 0) {
      icon = Icon(
        Icons.battery_1_bar,
        color: color,
      );
    } else {
      icon = Icon(
        Icons.battery_0_bar,
        color: color,
      );
    }

    return icon;
  }
}
