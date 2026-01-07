import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTextTitleSection extends ConsumerWidget {
  const AppTextTitleSection(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}
