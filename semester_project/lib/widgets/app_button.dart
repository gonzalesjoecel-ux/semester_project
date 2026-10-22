import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AppButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(onPressed: onPressed, child: Text(label)),
  );
}
