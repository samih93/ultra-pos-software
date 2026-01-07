import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionsHeader extends ConsumerWidget {
  const SubscriptionsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLtr = ref.read(mainControllerProvider).isLtr;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DefaultTextView(
            textAlign: isLtr ? TextAlign.left : TextAlign.right,
            text: S.of(context).customerName,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: DefaultTextView(
              text: S.of(context).paymentCount,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: DefaultTextView(
              text: S.of(context).totalPaid,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
