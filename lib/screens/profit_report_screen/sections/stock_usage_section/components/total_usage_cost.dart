import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TotalUsageCost extends ConsumerWidget {
  const TotalUsageCost({super.key, required this.totalCost});

  final double totalCost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return context.isMobile
        ? kEmptyWidget
        : Column(
            children: [
              Row(
                children: [
                  const Expanded(flex: 3, child: kEmptyWidget),
                  const Expanded(flex: 1, child: kEmptyWidget),
                  const Expanded(flex: 1, child: kEmptyWidget),
                  const Expanded(flex: 1, child: kEmptyWidget),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: kPadd8,
                      decoration: BoxDecoration(
                        color: Pallete.coreMistColor,
                        borderRadius: kRadius15,
                      ),
                      child: DefaultTextView(
                        textAlign: TextAlign.center,
                        text: "${totalCost.formatDouble()}",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}
