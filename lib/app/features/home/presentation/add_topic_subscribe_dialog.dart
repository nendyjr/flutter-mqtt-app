import 'package:flutter/material.dart';
import 'package:flutter_mqtt_app/app/widgets/app_textfield.dart';

class AddTopicSubscribeDialog extends StatelessWidget {
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
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
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return 'Topic tidak boleh kosong.';
                    }

                    return null;
                  },
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
                    child: Text('Cancel')),
                TextButton(
                    onPressed: () {
                      final isValid = formKey.currentState!.validate();
                      if (!isValid) return;

                      Navigator.of(context).pop(textController.text);
                    },
                    child: Text('Add')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
