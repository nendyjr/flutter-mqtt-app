import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.hintText, this.controller});

  final String hintText;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.justify,
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
