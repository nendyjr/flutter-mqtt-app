import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mqtt_app/app/core/client_connect.dart';
import 'package:flutter_mqtt_app/app/features/home/models/Receive_message.dart';
import 'package:flutter_mqtt_app/app/features/home/state/home_state.dart';
import 'package:mqtt_client/mqtt_client.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(InitialState());

  ClientConnect? client;

  List<String> topics = [];

  List<ReceiveMessage> messages = [];

  Future<void> connectToBroker(String host, int? port, String clientId) async {
    assert(host.isNotEmpty);

    client = ClientConnect(
      host: host,
      port: port,
      clientId: clientId,
      onListen: onListen,
      onConnected: onConnected,
      onDisconnected: onDisconnected,
      onSubscribed: onSubscribed,
      onSubscribeFail: onSubscribeFail,
      onUnsubscribed: onUnsubscribed,
      onAutoReconnect: onAutoReconnect,
      onConnectionFail: onConnectionFail,
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

    emit(TopicSubscribeState());

    client?.subscribeNewTopic(topic);
  }

  void onSubscribed(String topic) {
    topics.add(topic);

    emit(TopicSubscribedState());
  }

  void onSubscribeFail(String topic) {
    emit(ErrorState(error: 'Subscribe failed'));
  }

  void onUnsubscribed(String? topic) {
    topics.remove(topic);
    emit(TopicUnSubscribedState());
  }

  void onDisconnected() {
    if (client?.client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
      emit(DisconnectedState());
    } else {
      emit(ErrorState(error: 'You are disconected from the host'));
    }

    client = null;

    topics.clear();
  }

  void onConnectionFail(String error) {
    emit(ConnectingFailState());
    emit(ErrorState(error: error));
  }

  void unsubscribedTopic(String topic) {
    emit(TopicUnSubscribeState());
    client?.unsubscribeTopic(topic);
  }

  void onConnected() {
    messages.clear();
    topics.clear();

    emit(ConnectedState());
  }

  void onAutoReconnect() {}

  void onListen(List<MqttReceivedMessage<MqttMessage?>>? msgs) {
    if (msgs == null) return;
    emit(NewMessageReceivingState(messages: messages));

    for (final msg in msgs) {
      final mqttMsg = msg.payload as MqttPublishMessage;
      final realMsg = MqttPublishPayload.bytesToStringAsString(mqttMsg.payload.message);
      messages.insert(0, ReceiveMessage(message: realMsg, topic: msg.topic));
    }

    emit(NewMessageReceivedState(messages: messages));
  }
}
