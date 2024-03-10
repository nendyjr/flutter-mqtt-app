class Validator {
  static String? hostValidation(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Please fill host field';
    }

    const urlRegex =
        r'((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)';

    if (!RegExp(urlRegex).hasMatch(value)) {
      return 'Please fill correct host address';
    }

    return null;
  }

  static String? topicValidation(String? value, List<String> currentTopics) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Please fill topic name';
    }

    if (currentTopics.contains(value)) {
      return 'You are already subscribed to this topic';
    }

    return null;
  }
}
