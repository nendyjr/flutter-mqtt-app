import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mqtt_app/app/features/home/cubit/home_cubit.dart';
import 'package:flutter_mqtt_app/app/features/home/presentation/home_view.dart';

class MqttApp extends StatefulWidget {
  const MqttApp({super.key});

  @override
  State<MqttApp> createState() => _MqttAppState();

  // ignore: library_private_types_in_public_api
  static _MqttAppState of(BuildContext context) => context.findAncestorStateOfType<_MqttAppState>()!;
}

class _MqttAppState extends State<MqttApp> {
  // This widget is the root of your application.
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: BlocProvider(
        create: (_) => HomeCubit(),
        child: const MyHomePage(title: 'Flutter MQTT app'),
      ),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}
