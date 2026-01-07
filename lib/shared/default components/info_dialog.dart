import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import 'default_text_view.dart';

class InfoDialog extends ConsumerWidget {
  const InfoDialog({required this.title, required this.content, super.key});
  final String title;
  final Widget content;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      scrollable: true,
      title: Center(
        child: DefaultTextView(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          text: title,
        ),
      ),
      content: content,
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: DefaultTextView(text: S.of(context).yes),
        ),
      ],
    );
  }
}
