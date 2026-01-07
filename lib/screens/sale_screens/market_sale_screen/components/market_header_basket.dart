import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';

class MarketHeaderBasket extends StatelessWidget {
  const MarketHeaderBasket({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 4,
            child: Text(
              S.of(context).product,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        Expanded(
            child: Text(
          S.of(context).qty,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        Expanded(
            child: Text(
          S.of(context).price,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        Expanded(
            child: Text(
          S.of(context).totalPrice,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        Expanded(
            child: DefaultTextView(
          text: S.of(context).qtyInStock,
          fontWeight: FontWeight.bold,
        )),
      ],
    );
  }
}
