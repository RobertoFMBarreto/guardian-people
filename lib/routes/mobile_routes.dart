import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/pages/admin/mobile/admin_device_management_page.dart';
import 'package:guardian/pages/admin/mobile/admin_home_page.dart';
import 'package:guardian/pages/admin/mobile/admin_producer_page.dart';
import 'package:guardian/pages/login_page.dart';
import 'package:guardian/pages/producer/mobile/add_alert_page.dart';
import 'package:guardian/pages/producer/mobile/alerts_management_page.dart';
import 'package:guardian/pages/producer/mobile/alerts_page.dart';
import 'package:guardian/pages/producer/mobile/device_history_page.dart';
import 'package:guardian/pages/producer/mobile/device_page.dart';
import 'package:guardian/pages/producer/mobile/device_settings_page.dart';
import 'package:guardian/pages/producer/mobile/fences_page.dart';
import 'package:guardian/pages/producer/mobile/geofencing_page.dart';
import 'package:guardian/pages/producer/mobile/manage_fence_page.dart';
import 'package:guardian/pages/producer/mobile/producer_devices_page.dart';
import 'package:guardian/pages/producer/mobile/producer_home.dart';
import 'package:guardian/pages/producer/web/web_producer_page.dart';
import 'package:guardian/pages/profile_page.dart';
import 'package:guardian/pages/welcome_page.dart';

Map<String, Widget Function(BuildContext)> mobileRoutes = {
  '/': (context) => const WelcomePage(),
  '/login': (context) => const LoginPage(),
  '/profile': (context) => const ProfilePage(),
  '/admin': (context) => const AdminHomePage(),
  '/admin/producer': (context) {
    if (ModalRoute.of(context)!.settings.arguments.runtimeType == BigInt) {
      return AdminProducerPage(
        producerId: ModalRoute.of(context)!.settings.arguments as BigInt,
      );
    } else {
      throw ErrorDescription('Device not provided');
    }
  },
  '/admin/producer/device': (context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return AdminDeviceManagementPage(
        device: args['device'] as Animal,
        producerId: args['producerId'] as BigInt,
      );
    } else {
      throw ErrorDescription('Device not provided');
    }
  },
  '/producer': (context) => kIsWeb ? const WebProducerPage() : const ProducerHome(),
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
        idFence: data.containsKey('idFence') ? data['idFence'] as BigInt : null,
        idAlert: data.containsKey('idAlert') ? data['idAlert'] as BigInt : null,
        notToShowAnimals:
            data.containsKey('notToShowDevices') ? data['notToShowDevices'] as List<BigInt> : null,
      );
    } else {
      return const ProducerDevicesPage();
    }
  },
  '/producer/device': (context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return DevicePage(
        animal: data['device'] as Animal,
      );
    } else {
      throw ErrorDescription('Device not provided');
    }
  },
  '/producer/device/settings': (context) {
    if (ModalRoute.of(context)!.settings.arguments.runtimeType == Animal) {
      return DeviceSettingsPage(
        animal: ModalRoute.of(context)!.settings.arguments as Animal,
      );
    } else {
      throw ErrorDescription('Device not provided');
    }
  },
  '/producer/device/history': (context) {
    if (ModalRoute.of(context)!.settings.arguments.runtimeType == Animal) {
      return DeviceHistoryPage(
        animal: ModalRoute.of(context)!.settings.arguments as Animal,
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
  '/producer/alerts/management': (context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      final data = args as Map<String, dynamic>;
      return AlertsManagementPage(
        isSelect: data['isSelect'] as bool,
        idDevice: data['idDevice'] as String?,
      );
    } else {
      throw ErrorDescription('isSelect not provided');
    }
  },
};
