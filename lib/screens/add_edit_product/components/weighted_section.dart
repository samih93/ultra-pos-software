import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeightedSection extends ConsumerWidget {
  const WeightedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addEditcontroller = ref.watch(addEditProductControllerProvider);

    return AppTextFormField(
      showText: true,
      suffixIcon: SizedBox(
        width: context.width * 0.2,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DefaultTextView(
                textDecoration: addEditcontroller.isWeightedProduct
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
                text: S.of(context).weightedProduct,
                fontSize: 20,
                color: addEditcontroller.isWeightedProduct
                    ? context.primaryColor
                    : Colors.grey,
              ),
              Checkbox(
                value: addEditcontroller.isWeightedProduct,
                onChanged: (value) {
                  ref
                      .read(addEditProductControllerProvider)
                      .onChangeWeightedProductStatus();
                },
              ),
            ],
          ),
        ),
      ),
      inputtype: TextInputType.number,
      readonly: addEditcontroller.isWeightedProduct != true,
      format: numberTextFormatter,
      controller: addEditcontroller.pluTextContoller,
      hinttext: "PLU(5 digits)",
      onvalidate: (value) {
        if (addEditcontroller.isWeightedProduct &&
            value != null &&
            value.trim().length != 5) {
          return "plu must be 5 digits";
        }
        return null;
      },
    );
  }
}
