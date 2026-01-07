import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_form.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeSellingDialog extends ConsumerWidget {
  const ChangeSellingDialog(this.productId, {super.key});
  final int productId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      content: DefaultTextFormField(
        autofocus: true,
        text: S.of(context).sellingPrice,
        format: numberTextFormatter,
        onfieldsubmit: (value) {
          double price = double.tryParse(value.toString()) ?? 0;
          ref
              .read(saleControllerProvider)
              .onChangeSellingPrice(productId, price);
          context.pop();
        },
      ),
    );
  }
}
