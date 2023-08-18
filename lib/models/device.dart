import 'package:guardian/models/alert.dart';
import 'package:guardian/models/device_data.dart';
import 'package:guardian/models/fence.dart';

class Device {
  final String imei;
  String color;
  bool isBlocked;
  final List<DeviceData> data;
  final List<Alert> alerts;
  final List<Fence> fences;

  Device({
    required this.imei,
    required this.color,
    required this.isBlocked,
    required this.data,
    required this.alerts,
    required this.fences,
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
