import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/invoice_item.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HoldInvoicesSection extends ConsumerWidget {
  const HoldInvoicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleController = ref.watch(saleControllerProvider);
    return Row(
      spacing: 10,
      children: [
        AppSquaredOutlinedButton(
          isDisabled: saleController.basketItems.isEmpty,
          onPressed: () {
            if (saleController.basketItems.isNotEmpty) {
              ref.read(saleControllerProvider).onHoldInvoice(context);
            }
          },
          child: const Icon(Icons.watch_later_outlined),
        ),
        AppSquaredOutlinedButton(
          isDisabled: saleController.tempReceipts.isEmpty,
          child: const Icon(Icons.remove_red_eye_outlined),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Center(
                  child: DefaultTextView(
                      fontWeight: FontWeight.bold,
                      text: S.of(context).viewOnHold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...saleController.tempReceipts.entries.map((e) {
                      return invoiceItem(context, ref, e.key, e.value.note);
                    })
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
