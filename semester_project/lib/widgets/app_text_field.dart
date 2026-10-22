import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}
