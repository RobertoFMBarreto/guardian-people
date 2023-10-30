import 'package:dart_amqp/dart_amqp.dart';

const kGDapiServerUrl = '192.168.10.71:7986';
final kRabbitMqSettings = ConnectionSettings(
  host: '192.168.10.71',
  authProvider: const PlainAuthenticator("admin", "admin"),
);
