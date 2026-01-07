import 'package:desktoppossystem/models/reports/subscribtion_state_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionItems extends ConsumerWidget {
  const SubscriptionItems(
    this.subscriptionModel, {
    this.backgroundColor = Colors.white,
    super.key,
  });

  final SubscribtionStateModel subscriptionModel;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLtr = ref.read(mainControllerProvider).isLtr;

    return ColoredBox(
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DefaultTextView(
              textAlign: isLtr ? TextAlign.left : TextAlign.right,
              text: subscriptionModel.customerName,
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: DefaultTextView(
                text: subscriptionModel.paymentCount.toString(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DefaultTextView(
                text: subscriptionModel.totalPaid.formatDouble().toString(),
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
