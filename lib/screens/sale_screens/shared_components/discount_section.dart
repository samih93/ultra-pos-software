import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/general_section.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscountSection extends ConsumerWidget {
  const DiscountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);
    UserModel usermodel =
        ref.watch(currentUserProvider) ?? UserModel.fakeUser();

    return usermodel.role?.name != AuthRole.waiterRole
        ? Row(
            children: [
              DefaultTextView(
                  text: "${S.of(context).discount} : ",
                  fontWeight: FontWeight.bold),
              AppSquaredOutlinedButton(
                  child: const Icon(Icons.remove),
                  onPressed: () {
                    double dis = ref.watch(allowNegativeDiscountProvider)
                        ? saleController.discount - 0.5
                        : (saleController.discount - 0.5) < 0
                            ? 0
                            : (saleController.discount - 0.5);
                    saleController.onchangeDiscount(dis);
                  }),
              Padding(
                padding: kPaddH3,
                child: Text(saleController.discount.toString()),
              ),
              AppSquaredOutlinedButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    double dis = (saleController.discount + 0.5) > 100
                        ? 100
                        : (saleController.discount + 0.5);
                    saleController.onchangeDiscount(dis);
                  }),
              const Text("%"),
              Expanded(
                child: SizedBox(
                  child: Slider(
                      value: saleController.discount,
                      max: 100,
                      min: ref.watch(allowNegativeDiscountProvider) ? -100 : 0,
                      activeColor: context.primaryColor,
                      onChanged: (value) {
                        saleController.onchangeDiscount(
                          value.roundToDouble(),
                        );
                      }),
                ),
              ),
            ],
          )
        : kEmptyWidget;
  }
}
