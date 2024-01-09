import 'package:dart_amqp/dart_amqp.dart';

const kGDapiServerUrl = '77.54.1.149:7986'; //'10.10.128.118:37986';
final kRabbitMqSettings = ConnectionSettings(
  host: '77.54.1.149', //'10.10.128.118',
  port: 5672, //35672,
  authProvider: const PlainAuthenticator("admin", "admin"),
);
