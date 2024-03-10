import 'dart:io';
import 'dart:ui';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
//broker.hivemq.com
//flutter_mqtt/testtopic

class ClientConnect {
  ClientConnect({
    required this.host,
    this.port,
    required this.onListen,
    required this.onDisconnected,
    required this.onConnected,
    required this.onSubscribed,
    required this.onSubscribeFail,
    required this.onUnsubscribed,
    required this.clientId,
    required this.onAutoReconnect,
    required this.onConnectionFail,
  }) {
    onInit();
  }

  final String host;
  final int? port;
  final String clientId;
  late final MqttServerClient client;
  final Function(List<MqttReceivedMessage<MqttMessage?>>) onListen;
  final VoidCallback onDisconnected;
  final VoidCallback onConnected;
  final VoidCallback onAutoReconnect;
  final Function(String) onSubscribed;
  final Function(String) onSubscribeFail;
  final Function(String?) onUnsubscribed;
  final Function(String) onConnectionFail;

  Future<void> onInit() async {
    client = MqttServerClient(host, clientId);
    if (port != null) client.port = port!;

    client
      ..logging(on: true)
      ..setProtocolV311()
      ..keepAlivePeriod = 60
      ..connectTimeoutPeriod = 2000 // milliseconds
      ..onDisconnected = onDisconnected
      ..onAutoReconnect = onAutoReconnect
      ..onConnected = onConnected
      ..onSubscribed = onSubscribed
      ..onSubscribeFail = onSubscribeFail
      ..onUnsubscribed = onUnsubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
  }

  Subscription? subscribeNewTopic(String topic) {
    return client.subscribe(topic, MqttQos.exactlyOnce);
  }

  void unsubscribeTopic(String topic) {
    client.unsubscribe(topic);
  }

  void publishMessageToTopic(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  Future<void> connect() async {
    try {
      await client.connect();
      client.updates?.listen(onListen);
    } on NoConnectionException catch (e) {
      onConnectionFail(e.toString());
    } on SocketException catch (e) {
      onConnectionFail(e.message);
    }
  }

  void disconnect() {
    client.disconnect();
  }
}
