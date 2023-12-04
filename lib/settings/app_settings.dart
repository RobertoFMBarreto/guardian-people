import 'package:dart_amqp/dart_amqp.dart';

const kGDapiServerUrl =
    '77.54.1.149:7986'; //'77.54.1.149:7986'; //'0d82-185-51-94-175.ngrok-free.app'; //'192.168.10.71:7986';
//'3834-185-51-94-175.ngrok-free.app'; // //
final kRabbitMqSettings = ConnectionSettings(
  host: '77.54.1.149',
  authProvider: const PlainAuthenticator("admin", "admin"),
);
