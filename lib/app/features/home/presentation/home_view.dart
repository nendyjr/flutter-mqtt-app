import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mqtt_app/app/features/home/cubit/home_cubit.dart';
import 'package:flutter_mqtt_app/app/features/home/presentation/add_topic_subscribe_dialog.dart';
import 'package:flutter_mqtt_app/app/features/home/presentation/list_topic_subscribed_sheet.dart';
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
              "Message",
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(vertical: 16),
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
                        return const Text('No Message at this moment');
                      }
                    }),
              ),
            )),
            BlocConsumer<HomeCubit, HomeState>(
                listenWhen: (previous, current) =>
                    current is ConnectedState ||
                    current is DisconnectedState ||
                    current is TopicSubscribed ||
                    current is TopicUnSubscribed,
                listener: (context, state) {
                  final snackBar = SnackBar(
                    content: Text('Yay! A SnackBar!'),
                    backgroundColor: Colors.green,
                    dismissDirection: DismissDirection.up,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 10, right: 10),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                buildWhen: (previous, current) => (current is InitialState ||
                    current is ConnectingState ||
                    current is ConnectedState ||
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
                                        readOnly: state is ConnectedState,
                                        validator: (value) {
                                          if (value == null || value.isEmpty || value.trim().isEmpty) {
                                            return 'Please fill host field.';
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 60, maxWidth: 80),
                                    child: AppTextField(
                                      hintText: 'Port',
                                      controller: portController,
                                      readOnly: state is ConnectedState,
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
                                      readOnly: state is ConnectedState,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      final isValid = formHostKey.currentState!.validate();
                                      if (!isValid) return;

                                      (state is ConnectedState)
                                          ? context.read<HomeCubit>().disconnectToBroker()
                                          : context.read<HomeCubit>().connectToBroker(
                                                hostController.text,
                                                portController.text.isNotEmpty ? int.parse(portController.text) : null,
                                                clientIdController.text,
                                              );
                                    },
                                    child: (state is ConnectedState) ? Icon(Icons.link_off) : Icon(Icons.link),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      if (state is ConnectedState)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  onPressed: () => _openDialog(context), child: Text('Add new topic subscription')),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                  onPressed: () => _openTopicsBottomSheet(context, context.read<HomeCubit>().topics),
                                  child: Icon(Icons.list)),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _openDialog(BuildContext context) async {
    final topic = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AddTopicSubscribeDialog();
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
