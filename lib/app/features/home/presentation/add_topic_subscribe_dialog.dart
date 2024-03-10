import 'package:flutter/material.dart';
import 'package:flutter_mqtt_app/app/utils/validator.dart';
import 'package:flutter_mqtt_app/app/widgets/app_textfield.dart';

class AddTopicSubscribeDialog extends StatelessWidget {
  AddTopicSubscribeDialog({super.key, required this.currentTopics});
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final List<String> currentTopics;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.only(top: 16),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add new topic',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: AppTextField(
                  hintText: 'Topic',
                  controller: textController,
                  validator: (value) => Validator.topicValidation(value, currentTopics),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('CANCEL', style: Theme.of(context).textTheme.bodyMedium)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      final isValid = formKey.currentState!.validate();
                      if (!isValid) return;

                      Navigator.of(context).pop(textController.text);
                    },
                    child: Text(
                      'ADD',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
