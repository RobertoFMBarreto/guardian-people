import 'package:flutter/material.dart';

/// This class allows access to icons providers of device widgets
class DeviceWidgetProvider {
  /// Method to get the device battery indicator icon [Widget] based on the [deviceBattery]
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

  /// Method to get the device battery indication icon [IconData] based on the [deviceBattery]
  static IconData getBatteryIcon({
    required int? deviceBattery,
    required Color color,
  }) {
    IconData icon;
    if (deviceBattery != null) {
      if (deviceBattery == 100) {
        icon = Icons.battery_full;
      } else if (deviceBattery <= 99 && deviceBattery > 85) {
        icon = Icons.battery_6_bar;
      } else if (deviceBattery <= 85 && deviceBattery > 50) {
        icon = Icons.battery_5_bar;
      } else if (deviceBattery <= 50 && deviceBattery > 25) {
        icon = Icons.battery_4_bar;
      } else if (deviceBattery <= 25 && deviceBattery > 10) {
        icon = Icons.battery_3_bar;
      } else if (deviceBattery <= 10 && deviceBattery > 5) {
        icon = Icons.battery_2_bar;
      } else if (deviceBattery <= 5 && deviceBattery > 0) {
        icon = Icons.battery_1_bar;
      } else {
        icon = Icons.battery_0_bar;
      }
    } else {
      icon = Icons.battery_0_bar;
    }

    return icon;
  }
}
