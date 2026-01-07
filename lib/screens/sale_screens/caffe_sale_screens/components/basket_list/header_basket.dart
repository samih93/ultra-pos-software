import 'package:desktoppossystem/generated/l10n.dart';
import 'package:flutter/material.dart';

class HeaderBasket extends StatelessWidget {
  const HeaderBasket({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 2,
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
      ],
    );
  }
}
