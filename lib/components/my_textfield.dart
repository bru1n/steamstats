import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Icon? prefixIcon;
  final String? hintText;
  final Color? color;
  final Widget? suffixIcon;

  const MyTextfield({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.hintText,
    this.color,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: color ?? Theme.of(context).colorScheme.onSurface,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: color ?? Theme.of(context).colorScheme.onSurface,
            width: 1,
          ),
        ),
        prefixIcon: prefixIcon,
        prefixIconColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        suffixIcon: suffixIcon,
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
