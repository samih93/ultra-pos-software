import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBarTitle extends ConsumerWidget {
  const AppBarTitle({required this.title, super.key});

  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTextView(
      text: title.validateString(),
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );
  }
}
