import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/quotation_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotationButton extends ConsumerWidget {
  const QuotationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);

    return ref.read(mainControllerProvider).screenUI == ScreenUI.market
        ? ElevatedButtonWidget(
            text: S.of(context).quotation,
            // states: [
            //   ref
            //       .watch(receiptControllerProvider)
            //       .printQuotationRequestState
            // ],
            isDisabled: saleController.basketItems.isEmpty,
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => const QuotationDialog(),
              );
            },
          )
        : kEmptyWidget;
  }
}
