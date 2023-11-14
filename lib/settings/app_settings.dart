import 'package:dart_amqp/dart_amqp.dart';

const kGDapiServerUrl = 'localhost:7986'; //'192.168.10.71:7986';
final kRabbitMqSettings = ConnectionSettings(
  host: 'localhost', //'192.168.10.71',
  authProvider: const PlainAuthenticator("admin", "admin"),
);
