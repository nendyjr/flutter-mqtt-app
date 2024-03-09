import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
  });

  final String hintText;
  final TextEditingController? controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        counterText: '',
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      maxLines: 1,
    );
  }
}
