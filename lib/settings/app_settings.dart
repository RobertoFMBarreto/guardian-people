import 'package:dart_amqp/dart_amqp.dart';

const kGDapiServerUrl = '10.10.128.118:37986'; //'77.54.1.149:7986';
final kRabbitMqSettings = ConnectionSettings(
  host: '10.10.128.118', //'77.54.1.149',
  port: 35672,
  authProvider: const PlainAuthenticator("admin", "admin"),
);
