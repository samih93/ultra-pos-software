import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main_screen.dart/main_controller.dart';

class BuildHeaderDialog extends ConsumerWidget {
  const BuildHeaderDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DefaultTextView(
            text: S.of(context).product,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          flex: 1,
          child: DefaultTextView(
            fontWeight: FontWeight.bold,
            text: S.of(context).qty,
            fontSize: 12,
          ),
        ),
        if (ref.watch(mainControllerProvider).isSuperAdmin)
          Expanded(
            flex: 1,
            child: DefaultTextView(
              fontWeight: FontWeight.bold,
              text: S.of(context).costPrice,
              fontSize: 12,
            ),
          ),
        Expanded(
          flex: 1,
          child: DefaultTextView(
            fontWeight: FontWeight.bold,
            text: S.of(context).sellingPrice,
            fontSize: 12,
          ),
        ),
        Expanded(
          flex: 1,
          child: DefaultTextView(
            fontWeight: FontWeight.bold,
            text: S.of(context).totalAmount,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
