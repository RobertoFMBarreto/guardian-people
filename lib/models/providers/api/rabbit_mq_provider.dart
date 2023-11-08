import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter/foundation.dart';
import 'package:guardian/settings/app_settings.dart';

/// This class is the provider of RabbitMQ
class RabbitMQProvider {
  late Consumer consumer;

  Future<void> listen({
    required String topicId,
    required Function(Map<dynamic, dynamic>) onDataReceived,
  }) async {
    Client client = Client(settings: kRabbitMqSettings);

    Channel channel =
        await client.channel(); // auto-connect to localhost:5672 using guest credentials
    Queue queue = await channel.queue(topicId, durable: true, autoDelete: true);
    consumer = await queue.consume();
    if (kDebugMode) {
      print(' [x] Listenning for tracking data');
    }
    consumer.listen((AmqpMessage message) {
      // Or unserialize to json
      if (kDebugMode) {
        print(" [x] Received json: ${message.payloadAsJson}");
      }
      onDataReceived(message.payloadAsJson);
    });
  }

  Future<void> stop() async {
    await consumer.cancel();
  }
}
