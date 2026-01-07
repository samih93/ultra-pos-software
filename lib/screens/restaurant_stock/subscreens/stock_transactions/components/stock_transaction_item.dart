import 'package:desktoppossystem/models/stock_transaction_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockTransactionItem extends ConsumerWidget {
  const StockTransactionItem({required this.model, this.isWasteOut, super.key});
  final StockTransactionModel model;
  final bool? isWasteOut;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Center(
                child: DefaultTextView(
              text: model.itemName,
            ))),
        Center(
            child: DefaultTextView(
          text: "${model.unitType.uniteTypeToString()}",
        )),
        if (isWasteOut != true)
          Expanded(
            child: Center(
                child: DefaultTextView(
              text: "${model.oldQty ?? '--'}",
            )),
          ),
        Expanded(
          child: Center(
              child: DefaultTextView(
            text: "${model.transactionQty}",
          )),
        ),
        Expanded(
            child: Center(
                child: DefaultTextView(
          text: model.pricePerUnit.formatDouble().toString(),
        ))),
        Expanded(
            flex: 2,
            child: Center(
                child: DefaultTextView(
              text:
                  "${DateTime.parse(model.transactionDate).formatDateTime12Hours()}",
            ))),
        if (isWasteOut == true)
          Expanded(
              child: Center(
                  child: DefaultTextView(
            text: model.transactionReason ?? "--",
          ))),
        Expanded(
            flex: 1,
            child: Center(
                child: DefaultTextView(
                    text: "${model.employeeName}",
                    fontWeight: FontWeight.bold))),
      ],
    );
  }
}
