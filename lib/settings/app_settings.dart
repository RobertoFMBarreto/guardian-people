import 'package:dart_amqp/dart_amqp.dart';

const kGDapiServerUrl = '2ea6-185-51-94-175.ngrok-free.app'; //'192.168.10.71:7986';
final kRabbitMqSettings = ConnectionSettings(
  host: '6052-185-51-94-175.ngrok-free.app', //'192.168.10.71',
  authProvider: const PlainAuthenticator("admin", "admin"),
);
