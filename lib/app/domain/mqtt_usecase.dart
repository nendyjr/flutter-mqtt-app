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
  }) {
    client = MqttServerClient(host, 'clientId-kXcwNN1paJ');
    onInit();
  }

  final String host;
  final int? port;
  late final MqttServerClient client;
  final Function(List<MqttReceivedMessage<MqttMessage?>>) onListen;
  final VoidCallback onDisconnected;
  final VoidCallback onConnected;
  final Function(String) onSubscribed;
  final Function(String) onSubscribeFail;
  final Function(String?) onUnsubscribed;

  var pongCount = 0;

  Future<void> onInit() async {
    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    // client.useWebSocket = true;
    if (port != null) client.port = port!;

    /// There is also an alternate websocket implementation for specialist use, see useAlternateWebSocketImplementation
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.
    /// You can also supply your own websocket protocol list or disable this feature using the websocketProtocols
    /// setter, read the API docs for further details here, the vast majority of brokers will support the client default
    /// list so in most cases you can ignore this.

    /// Set logging on if needed, defaults to off
    client.logging(on: true);

    /// Set the correct MQTT protocol for mosquito == broker
    client.setProtocolV311();

    /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
    client.keepAlivePeriod = 20;

    /// The connection timeout period can be set if needed, the default is 5 seconds.
    client.connectTimeoutPeriod = 2000; // milliseconds

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the broker
    /// rejects the subscribe request.
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.onUnsubscribed = onUnsubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received
    /// from the broker.
    client.pongCallback = pong;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password and clean session,
    /// an example of a specific one below.
    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    // await connect();

    /// Ok, lets try a subscription
    // print('EXAMPLE::Subscribing to the test/lol topic');
    // const topic = 'test/lol'; // Not a wildcard topic
    // client.subscribe(topic, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    /// In general you should listen here as soon as possible after connecting, you will not receive any
    /// publish messages until you do this.
    /// Also you must re-listen after disconnecting.

    /// Lets publish to our topic
    /// Use the payload builder rather than a raw buffer
    /// Our known topic to publish to
    // subscribeNewTopic();

    /// Publish it

    /// Ok, we will now sleep a while, in this gap you will see ping request/response
    /// messages being exchanged by the keep alive mechanism.
    // print('EXAMPLE::Sleeping....');
    // await MqttUtilities.asyncSleep(60);

    /// Finally, unsubscribe and exit gracefully
    // print('EXAMPLE::Unsubscribing');

    /// Wait for the unsubscribe message from the broker if you wish.
    // await MqttUtilities.asyncSleep(2);

    // return 0;
  }

  Subscription? subscribeNewTopic(String topic) {
    /// Subscribe to it
    print('EXAMPLE::Subscribing to the Dart/Mqtt_client/testtopic topic');
    return client.subscribe(topic, MqttQos.exactlyOnce);
  }

  void unsubscribeTopic() {
    const topic = 'test/lol';
    client.unsubscribe(topic);
  }

  void publishMessageToTopic() {
    const pubTopic = 'flutter_mqtt/testtopic';
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello from mqtt_client');
    print('EXAMPLE::Publishing our topic');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);
  }

  Future<void> connect() async {
    try {
      await client.connect();
      client.updates?.listen(onListen);

      /// If needed you can listen for published messages that have completed the publishing
      /// handshake which is Qos dependant. Any message received on this stream has completed its
      /// publishing handshake with the broker.
      client.published?.listen((MqttPublishMessage message) {
        print(
            'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
      });
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print('EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }

  void disconnect() {
    print('EXAMPLE::Disconnecting');
    client.disconnect();
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
    pongCount++;
  }
}
