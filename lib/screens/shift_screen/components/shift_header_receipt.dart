import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShiftHeaderReceipt extends ConsumerWidget {
  const ShiftHeaderReceipt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var receiptController = ref.watch(receiptControllerProvider);

    return Row(
      children: [
        Expanded(
            child: DefaultTextView(
          text: S.of(context).receiptNumber,
          fontWeight: FontWeight.bold,
        )),
        Expanded(
            child: Center(
                child: DefaultTextView(
                    text: S.of(context).time, fontWeight: FontWeight.bold))),
        Expanded(
            child: Center(
          child: DefaultTextView(
              text: '(${AppConstance.primaryCurrency.currencyLocalization()})',
              fontWeight: FontWeight.bold),
        )),
        Expanded(
            child: Center(
          child: DefaultTextView(
              text: '${AppConstance.secondaryCurrency.currencyLocalization()}',
              fontWeight: FontWeight.bold),
        )),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: DefaultTextView(
                    text: S.of(context).paymentType,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => RotationTransition(
                          turns: receiptController.sortShiftByPaymentType
                              ? Tween<double>(begin: 1, end: 0).animate(anim)
                              : Tween<double>(begin: 0, end: 1).animate(anim),
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                    child: receiptController.sortShiftByPaymentType
                        ? Icon(Icons.arrow_upward_rounded,
                            color: context.primaryColor,
                            key: const ValueKey('icon1'))
                        : Icon(
                            color: context.primaryColor,
                            Icons.arrow_downward_rounded,
                            key: const ValueKey('icon2'),
                          )),
                onPressed: () {
                  ref
                      .read(receiptControllerProvider)
                      .sortShiftReceiptByPaymentType();
                },
              ),
            ],
          ),
        ),
        Expanded(
            child: Center(
                child: DefaultTextView(
                    text: S.of(context).detailsButton,
                    fontWeight: FontWeight.bold)))
      ],
    );
  }
}
