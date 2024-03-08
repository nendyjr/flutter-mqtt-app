import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mqtt_app/app/domain/mqtt_usecase.dart';
import 'package:flutter_mqtt_app/app/features/home/cubit/home_cubit.dart';
import 'package:flutter_mqtt_app/app/features/home/presentation/add_topic_subscribe_dialog.dart';
import 'package:flutter_mqtt_app/app/features/home/state/home_state.dart';
import 'package:flutter_mqtt_app/app/mqtt_app.dart';
import 'package:flutter_mqtt_app/app/widgets/app_textfield.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool _isDarkMode;

  @override
  initState() {
    super.initState();
  }

  bool isDarkMode(context) => Theme.of(context).brightness == Brightness.dark;

  void changeThemeMode() {
    setState(() {
      _isDarkMode = isDarkMode(context);
    });

    MqttApp.of(context).changeTheme(_isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
                maximumSize: Size(65, 40), //////// HERE
              ),
              onPressed: () => changeThemeMode(),
              child: Icon(isDarkMode(context) ? Icons.light_mode : Icons.dark_mode),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "message",
              textAlign: TextAlign.start,
            ),
            Expanded(
                child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MessageItemView(
                      message: 'Hi test...!',
                      topic: 'tpics/1',
                    )
                  ],
                ),
              ),
            )),
            BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
              return Column(
                children: [
                  Form(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: AppTextField(
                                hintText: 'Input Host',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 44,
                            width: 100,
                            child: AppTextField(
                              hintText: '1334',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              (state is ConectedState)
                                  ? context.read<HomeCubit>().disconnectToBroker()
                                  : context.read<HomeCubit>().connectToBroker();
                            },
                            child: (state is ConectedState) ? Icon(Icons.link_off) : Icon(Icons.link),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state is ConectedState)
                    ElevatedButton(onPressed: () => _openDialog(context), child: Text('Add new topic subscription')),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _openDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddTopicSubscribeDialog();
      },
    );
  }
}

class MessageItemView extends StatelessWidget {
  const MessageItemView({super.key, required this.message, required this.topic});
  final String message;
  final String topic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('Message : $message'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('Topic : $topic'),
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: Colors.black),
        const SizedBox(height: 4),
      ],
    );
  }
}
