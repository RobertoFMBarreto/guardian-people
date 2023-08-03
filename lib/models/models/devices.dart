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
}
