import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/pages/admin/admin_device_management_page.dart';
import 'package:guardian/pages/admin/admin_home_page.dart';
import 'package:guardian/pages/admin/admin_producer_page.dart';
import 'package:guardian/pages/login_page.dart';
import 'package:guardian/pages/producer/add_alert_page.dart';
import 'package:guardian/pages/producer/alerts_management_page.dart';
import 'package:guardian/pages/producer/alerts_page.dart';
import 'package:guardian/pages/producer/device_history_page.dart';
import 'package:guardian/pages/producer/device_page.dart';
import 'package:guardian/pages/producer/device_settings_page.dart';
import 'package:guardian/pages/producer/fences_page.dart';
import 'package:guardian/pages/producer/geofencing_page.dart';
import 'package:guardian/pages/producer/manage_fence_page.dart';
import 'package:guardian/pages/producer/producer_devices_page.dart';
import 'package:guardian/pages/producer/producer_home.dart';
import 'package:guardian/pages/profile_page.dart';
import 'package:guardian/pages/welcome_page.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => const WelcomePage(),
  '/login': (context) => const LoginPage(),
  '/profile': (context) => const ProfilePage(),
  '/admin': (context) => const AdminHomePage(),
  '/admin/producer': (context) {
    if (ModalRoute.of(context)!.settings.arguments.runtimeType == String) {
      return AdminProducerPage(
        producerId: ModalRoute.of(context)!.settings.arguments as String,
      );
    } else {
      throw ErrorDescription('Device not provided');
    }
  },
  '/admin/producer/device': (context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return AdminDeviceManagementPage(
        device: args['device'] as Device,
        producerId: args['producerId'] as String,
      );
    } else {
      throw ErrorDescription('Device not provided');
    }
  },
  '/producer': (context) => const ProducerHome(),
  '/producer/fences': (context) {
    if (ModalRoute.of(context)!.settings.arguments.runtimeType == bool) {
      return FencesPage(
        isSelect: ModalRoute.of(context)!.settings.arguments as bool,
      );
    } else {
      return const FencesPage();
    }
  },
  '/producer/fence/manage': (context) {
    return ManageFencePage(
      fence: ModalRoute.of(context)!.settings.arguments as FenceData,
    );
  },
  '/producer/geofencing': (context) {
    if (ModalRoute.of(context)!.settings.arguments.runtimeType == FenceData) {
      return GeofencingPage(
        fence: ModalRoute.of(context)!.settings.arguments as FenceData,
      );
    } else {
      return const GeofencingPage();
    }
  },
  '/producer/devices': (context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      final data = (args as Map<String, dynamic>);

      return ProducerDevicesPage(
        isSelect: data['isSelect'] as bool,
        fenceId: data.containsKey('fenceId') ? data['fenceId'] as String : null,
        alertId: data.containsKey('alertId') ? data['alertId'] as String : null,
        notToShowDevices:
            data.containsKey('notToShowDevices') ? data['notToShowDevices'] as List<String> : null,
      );
    } else {
      return const ProducerDevicesPage();
    }
  },
  '/producer/device': (context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return DevicePage(
        device: data['device'] as Device,
      );
    } else {
      throw ErrorDescription('Device not provided');
    }
  },
  '/producer/device/settings': (context) {
    if (ModalRoute.of(context)!.settings.arguments.runtimeType == Device) {
      return DeviceSettingsPage(
        device: ModalRoute.of(context)!.settings.arguments as Device,
      );
    } else {
      throw ErrorDescription('Device not provided');
    }
  },
  '/producer/device/history': (context) {
    if (ModalRoute.of(context)!.settings.arguments.runtimeType == Device) {
      return DeviceHistoryPage(
        device: ModalRoute.of(context)!.settings.arguments as Device,
      );
    } else {
      throw ErrorDescription('Device not provided');
    }
  },
  '/producer/alerts': (context) => const AlertsPage(),
  '/producer/alerts/add': (context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      final data = args as Map<String, dynamic>;
      return AddAlertPage(
        isEdit: data['isEdit'] as bool,
        alert: data['alert'] as UserAlertCompanion,
      );
    } else {
      return const AddAlertPage();
    }
  },
  '/producer/alert/management': (context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      final data = args as Map<String, dynamic>;
      return AlertsManagementPage(
        isSelect: data['isSelect'] as bool,
        deviceId: data['deviceId'] as String?,
      );
    } else {
      throw ErrorDescription('isSelect not provided');
    }
  },
};
