import 'package:equatable/equatable.dart';
import 'package:flutter_mqtt_app/app/features/home/models/Receive_message.dart';

abstract class HomeState extends Equatable {}

class InitialState extends HomeState {
  @override
  List<Object> get props => [];
}

class MqttConnectionState extends HomeState {
  MqttConnectionState({required this.isConnected, this.error, required this.isLoading});

  final bool isConnected;
  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [];
}

class DisconnectedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class DisconnectedUnsolicitedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class ConnectingState extends HomeState {
  @override
  List<Object?> get props => [];
}

class ConnectingFailState extends HomeState {
  @override
  List<Object?> get props => [];
}

class ConnectedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class NewSubscribedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class NewMessageReceivingState extends HomeState {
  NewMessageReceivingState({required this.messages});
  final List<ReceiveMessage> messages;

  @override
  List<Object?> get props => [messages];
}

class NewMessageReceivedState extends HomeState {
  NewMessageReceivedState({required this.messages});
  final List<ReceiveMessage> messages;

  @override
  List<Object?> get props => [messages];
}

class ErrorState extends HomeState {
  ErrorState({required this.error});
  final String error;

  @override
  List<Object?> get props => [];
}

class TopicSubscribedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class TopicSubscribeState extends HomeState {
  @override
  List<Object?> get props => [];
}

class TopicUnSubscribeState extends HomeState {
  @override
  List<Object?> get props => [];
}

class TopicUnSubscribedState extends HomeState {
  @override
  List<Object?> get props => [];
}
