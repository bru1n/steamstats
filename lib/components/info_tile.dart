import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Color? color;
  final Widget? trailing;

  const InfoTile({
    super.key,
    required this.title,
    this.subtitle,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        ),
      ),
    );
  }
}
