import 'package:collection/collection.dart';

T? parseEnum<T>(List<T> values, String value) {
  return values.firstWhereOrNull((v) => v.toString().toLowerCase().split('.')[1] == value.toLowerCase());
}

String stringEnum<T>(T value) {
  return value.toString().split('.').last;
}
