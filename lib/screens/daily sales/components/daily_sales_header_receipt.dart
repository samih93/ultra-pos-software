import 'dart:async';

import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailySalesHeaderReceipt extends ConsumerStatefulWidget {
  const DailySalesHeaderReceipt({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DailySalesHeaderReceiptState();
}

class _DailySalesHeaderReceiptState
    extends ConsumerState<DailySalesHeaderReceipt> {
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      // Call your search function here
      ref.read(receiptControllerProvider).searchByInvoiceId(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    var receiptController = ref.watch(receiptControllerProvider);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: 100,
            child: AppTextFormField(
              format: numberDigitFormatter,
              onchange: (value) {
                _onSearchChanged(value);
              },
              hinttext: S.of(context).receiptId,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: DefaultTextView(
              text: S.of(context).time,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: DefaultTextView(
              text: '(${AppConstance.primaryCurrency.currencyLocalization()})',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: DefaultTextView(
              text: '${AppConstance.secondaryCurrency.currencyLocalization()}',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: DefaultTextView(
                  text: S.of(context).paymentType,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: receiptController.isSortByPaymentType
                        ? Tween<double>(begin: 1, end: 0).animate(anim)
                        : Tween<double>(begin: 0, end: 1).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: receiptController.isSortByPaymentType
                      ? Icon(
                          Icons.arrow_upward_rounded,
                          color: context.primaryColor,
                          key: const ValueKey('icon1'),
                        )
                      : Icon(
                          color: context.primaryColor,
                          Icons.arrow_downward_rounded,
                          key: const ValueKey('icon2'),
                        ),
                ),
                onPressed: () {
                  ref
                      .read(receiptControllerProvider)
                      .sortReceiptByPaymentType();
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              Center(
                child: DefaultTextView(
                  text: S.of(context).manage,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTotalReceiptsCount(),
            ],
          ),
        ),
      ],
    );
  }

  _buildTotalReceiptsCount() {
    final showReceipts = ref.read(selectedFinancialFilterIndex) == 0;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: ref
          .watch(futureReceiptTotalsProvider)
          .when(
            data: (data) {
              return DefaultTextView(
                text:
                    "(${showReceipts ? data.totalInvoices : data.totalPendingReceipts})",
                fontWeight: FontWeight.bold,
                fontSize: 16,
              );
            },
            error: (Object error, StackTrace stackTrace) {
              return kEmptyWidget;
            },
            loading: () {
              return kEmptyWidget;
            },
          ),
    );
  }
}
