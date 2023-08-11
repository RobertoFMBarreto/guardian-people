import 'package:guardian/models/device_data.dart';

class Device {
  final String imei;
  String color;
  bool isBlocked;
  final List<DeviceData> data;

  Device({
    required this.imei,
    required this.color,
    required this.isBlocked,
    required this.data,
  });

  List<DeviceData> getDataBetweenDates(DateTime startDate, DateTime endDate) {
    List<DeviceData> gottenData = [];

    gottenData.addAll(
      data.where(
        (dataItem) => dataItem.dateTime.isAfter(startDate) && dataItem.dateTime.isBefore(endDate),
      ),
    );

    return gottenData;
  }
}
