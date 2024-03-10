import 'package:flutter/material.dart';

class ListTopicSubscribedSheet extends StatelessWidget {
  const ListTopicSubscribedSheet({super.key, required this.topics});
  final List<String> topics;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Topics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.black,
              margin: const EdgeInsets.only(bottom: 8),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...topics.map(
                      (topic) => TopicItemView(
                        topic: topic,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TopicItemView extends StatelessWidget {
  const TopicItemView({
    super.key,
    required this.topic,
  });
  final String topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(topic)),
          IconButton(
              onPressed: () async {
                final topicWilldelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return UnsubscribeConfirmationDialog(
                      topic: topic,
                    );
                  },
                );

                if (topicWilldelete == null || topicWilldelete.isEmpty) return;

                Navigator.of(context).pop(topicWilldelete);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.red,
              ))
        ],
      ),
    );
  }
}

class UnsubscribeConfirmationDialog extends StatelessWidget {
  final String topic;

  const UnsubscribeConfirmationDialog({super.key, required this.topic});
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Are you sure wants to unsub $topic ?',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(topic);
                    },
                    child: const Text('Yes')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
