import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// **Expenses Header (Same Style as Sales Header)**
class ExpensesHeader extends ConsumerWidget {
  const ExpensesHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Center(
                child: DefaultTextView(
              text: S.of(context).name,
              fontWeight: FontWeight.bold,
            ))),
        Expanded(
            flex: 2,
            child: Center(
                child: DefaultTextView(
                    text: S.of(context).amount, fontWeight: FontWeight.bold))),
        const Expanded(
            child: Center(
                child:
                    DefaultTextView(text: "%", fontWeight: FontWeight.bold))),
      ],
    );
  }
}
