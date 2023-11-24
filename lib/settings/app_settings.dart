import 'package:dart_amqp/dart_amqp.dart';

const kGDapiServerUrl =
    'fd68-5-249-105-156.ngrok-free.app'; //'0d82-185-51-94-175.ngrok-free.app'; //'192.168.10.71:7986';
//'3834-185-51-94-175.ngrok-free.app'; // //
final kRabbitMqSettings = ConnectionSettings(
  host: '192.168.10.71',
  authProvider: const PlainAuthenticator("admin", "admin"),
);
