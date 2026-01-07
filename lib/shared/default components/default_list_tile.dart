import 'package:flutter/material.dart';

class DefaultListTile extends StatelessWidget {
  const DefaultListTile(
      {this.onTap,
      required this.title,
      this.leading,
      this.trailing,
      this.subtitle,
      this.tileColor,
      super.key});
  final VoidCallback? onTap;
  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;
  final Color? tileColor;
  @override
  Widget build(BuildContext context) {
    return ListTile(
        tileColor: tileColor,
        dense: true,
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        title: title);
  }
}
