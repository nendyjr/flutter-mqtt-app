import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mqtt_app/app/domain/mqtt_usecase.dart';
import 'package:flutter_mqtt_app/app/features/home/models/Receive_message.dart';
import 'package:flutter_mqtt_app/app/features/home/state/home_state.dart';
import 'package:mqtt_client/mqtt_client.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(InitialState());

  ClientConnect? client;

  List<String> topics = [];

  List<ReceiveMessage> messages = [];

  Future<void> connectToBroker(String host, int? port) async {
    assert(host.isNotEmpty);

    client = ClientConnect(
      host: host,
      port: port,
      onListen: onListen,
      onConnected: onConnected,
      onDisconnected: onDisconnected,
      onSubscribed: onSubscribed,
      onSubscribeFail: onSubscribeFail,
      onUnsubscribed: onUnsubscribed,
    );
    emit(ConnectingState());
    await client!.connect();
  }

  Future<void> disconnectToBroker() async {
    client!.disconnect();
  }

  void subscribeNewTopic(String topic) {
    assert(topic.isNotEmpty);
    assert(client != null);

    final sub = client?.subscribeNewTopic(topic);
    if (sub == null) return;

    // topics.add(sub.topic.rawTopic);

    // client?.publishMessageToTopic();
  }

  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
    topics.add(topic);
  }

  void onSubscribeFail(String topic) {
    print('EXAMPLE::Subscription failed for topic $topic');
  }

  void onUnsubscribed(String? topic) {
    print('EXAMPLE::Unsubscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client?.client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      print('EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
    }

    client = null;
    emit(DisconnectedState());
  }

  /// The successful connect callback
  void onConnected() {
    print('EXAMPLE::OnConnected client callback - Client connection was successful');

    emit(ConnectedState());
  }

  void onListen(List<MqttReceivedMessage<MqttMessage?>>? c) {
    emit(NewMessageReceivingState(messages: messages));
    final recMess = c![0].payload as MqttPublishMessage;
    for (final msg in c) {
      final mqttMsg = msg.payload as MqttPublishMessage;
      final realMsg = MqttPublishPayload.bytesToStringAsString(mqttMsg.payload.message);
      messages.add(ReceiveMessage(message: realMsg, topic: msg.topic));
    }
    final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    emit(NewMessageReceivedState(messages: messages));

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    print('');
  }
}
