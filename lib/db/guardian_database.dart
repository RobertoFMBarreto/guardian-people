import 'package:guardian/models/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Device/device_data.dart';
import 'package:guardian/models/data_models/Fence/fence_devices.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/data_models/Fences/fence_points.dart';
import 'package:guardian/models/data_models/user.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GuardianDatabase {
  static final GuardianDatabase instance = GuardianDatabase._init();

  static Database? _database;

  GuardianDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('guardian.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onCreate: (Database database, int version) async {
        await _createDB(database, version);
      },
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY NOT NULL';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const doubleType = 'REAL NOT NULL';

    // Create user table
    await db.execute("""
      CREATE TABLE $tableUser(
        ${UserFields.uid} $idType,
        ${UserFields.name} $textType,
        ${UserFields.email} $textType,
        ${UserFields.phone} $intType,
        ${UserFields.isAdmin} $boolType
      )""");

    // Create devices table
    await db.execute("""
      CREATE TABLE $tableDevices (
        ${DeviceFields.id} $idType,
        ${DeviceFields.deviceId} $textType,
        ${DeviceFields.imei} $textType,
        ${DeviceFields.color} $textType,
        ${DeviceFields.name} $textType,
        ${DeviceFields.isActive} $boolType
      )""");

    // Create device data table
    await db.execute("""
      CREATE TABLE $tableDeviceData (
        ${DeviceDataFields.id} $idType,
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
      CREATE TABLE $tableUserAlerts (
        ${UserAlertFields.id} $idType,
        ${UserAlertFields.alertId} $textType,
        ${UserAlertFields.hasNotification} $boolType,
        ${UserAlertFields.parameter} $textType,
        ${UserAlertFields.comparisson} $textType,
        ${UserAlertFields.value} $doubleType
      )""");

    // Create alert devices table
    await db.execute("""
      CREATE TABLE $tableAlertDevices (
        ${AlertDevicesFields.id} $idType,
        ${AlertDevicesFields.alertId} $textType,
        ${AlertDevicesFields.deviceId} $textType
      )""");

    // Create fences table
    await db.execute("""
      CREATE TABLE $tableFence (
        ${FenceFields.id} $idType,
        ${FenceFields.fenceId} $textType,
        ${FenceFields.name} $textType,
        ${FenceFields.color} $textType
      )""");

    // Create fence devices table
    await db.execute("""
      CREATE TABLE $tableFenceDevices (
        ${FenceDevicesFields.id} $idType,
        ${FenceDevicesFields.fenceId} $textType,
        ${FenceDevicesFields.deviceId} $textType
      )""");

    // Create fence points table
    await db.execute("""
      CREATE TABLE $tableFencePoints (
        ${FencePointsFields.id} $idType,
        ${FencePointsFields.fenceId} $textType,
        ${FencePointsFields.lat} $doubleType
        ${FencePointsFields.lon} $doubleType
      )""");
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
