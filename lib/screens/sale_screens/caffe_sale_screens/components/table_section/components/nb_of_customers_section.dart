import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NbOfCustomersSection extends ConsumerWidget {
  const NbOfCustomersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleController = ref.watch(saleControllerProvider);
    return Row(
      children: [
        DefaultTextView(
          text: "${S.of(context).numberOfCustomers} :  ",
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        AppSquaredOutlinedButton(
          size: const Size(30, 30),
          child: const Icon(Icons.remove),
          onPressed: () {
            ref.read(saleControllerProvider).decreaseCustomers();
          },
        ),
        kGap5,
        SizedBox(
          width: 35,
          child: DefaultTextView(
            textAlign: TextAlign.center,
            text: "(${saleController.nbOfCustomers})",
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: context.primaryColor,
          ),
        ),
        kGap5,
        AppSquaredOutlinedButton(
          size: const Size(30, 30),
          child: const Icon(Icons.add),
          onPressed: () {
            ref.read(saleControllerProvider).increaseCustomers();
          },
        ),
      ],
    );
  }
}
