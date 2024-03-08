import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mqtt_app/app/features/home/state/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(InitialState());

  Future<void> connectToBroker() async {
    emit(ConectedState());
  }

  Future<void> disconnectToBroker() async {
    emit(DisconnectedState());
  }
}
