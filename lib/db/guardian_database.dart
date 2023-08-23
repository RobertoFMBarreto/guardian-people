import 'package:guardian/models/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/data_models/Alerts/alert_notifications.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Device/device_data.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/data_models/Fences/fence_devices.dart';
import 'package:guardian/models/data_models/Fences/fence_points.dart';
import 'package:guardian/models/data_models/user.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GuardianDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('guardian.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 10,
      onCreate: (Database database, int version) async {
        await _createDB(database, version);
      },
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY NOT NULL';
    const idIncrementType = 'INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const doubleType = 'REAL NOT NULL';

    // Create user table
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableUser(
        ${UserFields.uid} $idType,
        ${UserFields.name} $textType,
        ${UserFields.email} $textType,
        ${UserFields.phone} $intType,
        ${UserFields.isAdmin} $boolType
      )""");

    // Create devices table
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableDevices (
        ${DeviceFields.deviceId} $idType,
        ${DeviceFields.uid} $textType,
        ${DeviceFields.imei} $textType,
        ${DeviceFields.color} $textType,
        ${DeviceFields.name} $textType,
        ${DeviceFields.isActive} $boolType
      )""");

    // Create device data table
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableDeviceData (
        ${DeviceDataFields.deviceDataId} $idIncrementType,
        ${DeviceDataFields.deviceId} $textType,
        ${DeviceDataFields.dataUsage} $intType,
        ${DeviceDataFields.temperature} $doubleType,
        ${DeviceDataFields.battery} $intType,
        ${DeviceDataFields.lat} $doubleType,
        ${DeviceDataFields.lon} $doubleType,
        ${DeviceDataFields.elevation} $doubleType,
        ${DeviceDataFields.accuracy} $doubleType,
        ${DeviceDataFields.dateTime} $textType,
        ${DeviceDataFields.state} $textType
      )""");

    // Create user alerts table
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableUserAlerts (
        ${UserAlertFields.alertId} $idType,
        ${UserAlertFields.deviceId} $textType,
        ${UserAlertFields.uid} $textType,
        ${UserAlertFields.hasNotification} $boolType,
        ${UserAlertFields.parameter} $textType,
        ${UserAlertFields.comparisson} $textType,
        ${UserAlertFields.value} $doubleType
      )""");

    // Create alert devices table
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableAlertDevices (
        ${AlertDevicesFields.alertDevicesId} $idIncrementType,
        ${AlertDevicesFields.alertId} $textType,
        ${AlertDevicesFields.deviceId} $textType
      )""");

    // Create alert notifications table
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableAlertNotification (
        ${AlertNotificationFields.notificationId} $idIncrementType,
        ${AlertNotificationFields.alertId} $textType,
        ${AlertNotificationFields.uid} $textType,
        ${AlertNotificationFields.deviceId} $textType
      )""");

    // Create fences table
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableFence (
        ${FenceFields.fenceId} $idType,
        ${FenceFields.uid} $textType,
        ${FenceFields.name} $textType,
        ${FenceFields.color} $textType
      )""");

    // Create fence devices table
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableFenceDevices (
        ${FenceDevicesFields.fenceDevicesId} $idIncrementType,
        ${FenceDevicesFields.fenceId} $textType,
        ${FenceDevicesFields.deviceId} $textType
      )""");

    // Create fence points table
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableFencePoints (
        ${FencePointsFields.fencePointsId} $idIncrementType,
        ${FencePointsFields.fenceId} $textType,
        ${FencePointsFields.lat} $doubleType,
        ${FencePointsFields.lon} $doubleType
      )""");
  }

  Future close() async {
    final db = await database;

    db.close();
  }
}
