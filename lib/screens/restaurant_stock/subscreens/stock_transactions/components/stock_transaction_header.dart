import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockTransactionHeader extends ConsumerWidget {
  const StockTransactionHeader({this.isWasteOut, this.isStaff, super.key});
  final bool? isWasteOut;
  final bool? isStaff;
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
        Center(
            child: DefaultTextView(
                text: "${S.of(context).unit} ", fontWeight: FontWeight.bold)),
        if (isWasteOut != true)
          Expanded(
            child: Center(
                child: DefaultTextView(
                    text: "${S.of(context).oldQty} ",
                    fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: Center(
              child: DefaultTextView(
                  text: "${S.of(context).qty} ", fontWeight: FontWeight.bold)),
        ),
        Expanded(
            child: Center(
                child: DefaultTextView(
                    text: S.of(context).pricePerUnit,
                    fontWeight: FontWeight.bold))),
        Expanded(
            flex: 2,
            child: Center(
                child: DefaultTextView(
                    text: S.of(context).date, fontWeight: FontWeight.bold))),
        if (isWasteOut == true && isStaff != true)
          Expanded(
              flex: 1,
              child: Center(
                  child: DefaultTextView(
                      text: S.of(context).wasteReason,
                      fontWeight: FontWeight.bold))),
        Expanded(
            flex: 1,
            child: Center(
                child: DefaultTextView(
                    text: "${S.of(context).by} ${S.of(context).user}",
                    fontWeight: FontWeight.bold))),
      ],
    );
  }
}
