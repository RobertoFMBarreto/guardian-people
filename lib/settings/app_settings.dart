import 'package:dart_amqp/dart_amqp.dart';

const kGDapiServerUrl =
    '8583-185-51-94-175.ngrok-free.app'; //'localhost:7986'; //'192.168.10.71:7986';
//'3834-185-51-94-175.ngrok-free.app'; // //
final kRabbitMqSettings = ConnectionSettings(
  host: '192.168.10.71',
  authProvider: const PlainAuthenticator("admin", "admin"),
);
