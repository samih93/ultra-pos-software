import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WasteHeader extends ConsumerWidget {
  const WasteHeader({super.key});

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
                    text:
                        "${S.of(context).qtyAsKg} / ${S.of(context).qtyAsPortions}",
                    fontWeight: FontWeight.bold))),
        Expanded(
            flex: 1,
            child: Center(
                child: DefaultTextView(
                    text: S.of(context).totalCost,
                    fontWeight: FontWeight.bold))),
        const Expanded(
            child: Center(
                child:
                    DefaultTextView(text: "%", fontWeight: FontWeight.bold))),
      ],
    );
  }
}
