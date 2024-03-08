import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {}

class InitialState extends HomeState {
  @override
  List<Object> get props => [];
}

class DisconnectedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class ConnectingState extends HomeState {
  @override
  List<Object?> get props => [];
}

class ConectedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class NewSubscribedState extends HomeState {
  @override
  List<Object?> get props => [];
}

class errorState extends HomeState {
  @override
  List<Object?> get props => [];
}
