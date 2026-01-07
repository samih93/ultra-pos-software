import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsSalesByCatgeoryHeader extends ConsumerWidget {
  const ProductsSalesByCatgeoryHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
            child: Center(
                child: DefaultTextView(
          text: S.of(context).category,
          fontWeight: FontWeight.bold,
        ))),
        Expanded(
            child: Center(
                child: DefaultTextView(
                    text: S.of(context).costPrice,
                    fontWeight: FontWeight.bold))),
        Expanded(
            child: Center(
                child: DefaultTextView(
                    text: S.of(context).sellingPrice,
                    fontWeight: FontWeight.bold))),
        Expanded(
            child: Center(
                child: DefaultTextView(
                    text: S.of(context).profit, fontWeight: FontWeight.bold))),
        Expanded(
            child: Center(
                child: DefaultTextView(
                    text: "${S.of(context).profit} %",
                    fontWeight: FontWeight.bold))),
      ],
    );
  }
}
