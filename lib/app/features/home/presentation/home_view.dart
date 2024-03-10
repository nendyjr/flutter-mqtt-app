import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mqtt_app/app/features/home/cubit/home_cubit.dart';
import 'package:flutter_mqtt_app/app/features/home/presentation/add_topic_subscribe_dialog.dart';
import 'package:flutter_mqtt_app/app/features/home/presentation/list_topic_subscribed_sheet.dart';
import 'package:flutter_mqtt_app/app/features/home/state/home_state.dart';
import 'package:flutter_mqtt_app/app/mqtt_app.dart';
import 'package:flutter_mqtt_app/app/utils/validator.dart';
import 'package:flutter_mqtt_app/app/widgets/app_textfield.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool _isDarkMode;
  final hostController = TextEditingController();
  final portController = TextEditingController();
  final clientIdController = TextEditingController();
  final formHostKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
  }

  bool isDarkMode(context) => Theme.of(context).brightness == Brightness.dark;
  HomeCubit get cubit => context.read<HomeCubit>();

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
                maximumSize: const Size(65, 40),
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
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Text(
                  "Message",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (previous, current) => (current is InitialState ||
                        current is ConnectingState ||
                        current is ConnectedState ||
                        current is DisconnectedState),
                    builder: (context, state) {
                      return Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: state is ConnectingState
                                ? Colors.grey
                                : state is ConnectedState
                                    ? Colors.green
                                    : Colors.grey,
                          ));
                    }),
                const SizedBox(width: 8),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey,
                child: SingleChildScrollView(
                  child: BlocBuilder<HomeCubit, HomeState>(
                      buildWhen: (previous, current) => (current is InitialState ||
                          current is NewMessageReceivedState ||
                          current is ConnectedState ||
                          current is DisconnectedState),
                      builder: (context, state) {
                        if (state is NewMessageReceivedState) {
                          return Column(
                            children: [
                              ...(state).messages.map((msg) => MessageItemView(
                                    message: msg.message,
                                    topic: msg.topic,
                                  )),
                            ],
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No Message at this moment'),
                          );
                        }
                      }),
                ),
              ),
            ),
            BlocConsumer<HomeCubit, HomeState>(
              listenWhen: (previous, current) =>
                  current is ConnectedState ||
                  current is DisconnectedState ||
                  current is TopicSubscribedState ||
                  current is TopicUnSubscribedState ||
                  current is ErrorState,
              listener: (context, state) {
                var message = '';
                var color = Colors.green;
                if (state is ConnectedState) {
                  message = 'You are connected with the host';
                  FocusManager.instance.primaryFocus?.unfocus();
                } else if (state is DisconnectedState) {
                  message = 'You are disconected with the host';
                  FocusManager.instance.primaryFocus?.unfocus();
                } else if (state is TopicSubscribedState) {
                  message = 'Subscription successful';
                } else if (state is TopicUnSubscribedState) {
                  message = 'Unsubscription successful';
                } else if (state is ErrorState) {
                  message = state.error;
                  color = Colors.red;
                }

                _showSnackBar(message, color, context);
              },
              buildWhen: (previous, current) => (current is InitialState ||
                  current is ConnectingState ||
                  current is ConnectedState ||
                  current is ConnectingFailState ||
                  current is DisconnectedState),
              builder: (context, state) {
                return Column(
                  children: [
                    Form(
                      key: formHostKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Connection',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: AppTextField(
                                      hintText: 'Host (required)',
                                      controller: hostController,
                                      readOnly: state is ConnectedState || state is ConnectingState,
                                      validator: Validator.hostValidation,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  ':',
                                  style: Theme.of(context).textTheme.headlineLarge,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  constraints: const BoxConstraints(minWidth: 60, maxWidth: 80),
                                  child: AppTextField(
                                    hintText: '1883',
                                    controller: portController,
                                    readOnly: state is ConnectedState || state is ConnectingState,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    hintText: 'Client Id',
                                    controller: clientIdController,
                                    readOnly: state is ConnectedState || state is ConnectingState,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: state is ConnectingState
                                      ? null
                                      : () {
                                          final isValid = formHostKey.currentState!.validate();
                                          if (!isValid) return;

                                          (state is ConnectedState)
                                              ? context.read<HomeCubit>().disconnectToBroker()
                                              : context.read<HomeCubit>().connectToBroker(
                                                    hostController.text,
                                                    portController.text.isNotEmpty
                                                        ? int.parse(portController.text)
                                                        : null,
                                                    clientIdController.text,
                                                  );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: state is ConnectedState ? Colors.red : Colors.green,
                                  ),
                                  child: (state is ConnectedState)
                                      ? const Icon(Icons.link_off, color: Colors.white)
                                      : (state is ConnectingState)
                                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                                          : const Icon(Icons.link, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
                        height: state is ConnectedState ? null : 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _openDialog(context),
                              child: const Text('Add new topic subscription'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                                onPressed: () => _openTopicsBottomSheet(context, context.read<HomeCubit>().topics),
                                child: const Icon(Icons.list)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, MaterialColor color, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 50, left: 10, right: 10),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _openDialog(BuildContext context) async {
    final topic = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AddTopicSubscribeDialog(
          currentTopics: cubit.topics,
        );
      },
    );

    if (topic == null || topic.isEmpty) return;

    context.read<HomeCubit>().subscribeNewTopic(topic);
  }

  Future<void> _openTopicsBottomSheet(BuildContext context, List<String> topics) async {
    final topic = await showModalBottomSheet<String?>(
      isScrollControlled: true,
      context: context,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListTopicSubscribedSheet(
          topics: topics,
        ),
      ),
    );

    if (topic == null) return;

    context.read<HomeCubit>().unsubscribedTopic(topic);
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
