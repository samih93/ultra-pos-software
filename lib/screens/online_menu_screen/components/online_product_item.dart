import 'package:desktoppossystem/controller/menu_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/online_menu_screen/sub_sreens/add_edit_menu_product_screen.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnlineProductItem extends ConsumerWidget {
  final ProductModel product;

  const OnlineProductItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: defaultRadius,
        border: Border.all(color: Pallete.greyColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Drag handle
          kGap5,
          // Product info - wrapped with InkWell
          Expanded(
            child: InkWell(
              onTap: () {
                if (ref.read(menuControllerProvider).selectedCategory == null) {
                  ToastUtils.showToast(message: S.of(context).selectCategory);
                  return;
                }
                context.to(
                  AddEditMenuProductScreen(
                    p: product,
                    c: ref.read(menuControllerProvider).selectedCategory!,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      DefaultTextView(
                        text: product.name ?? 'Unnamed Product',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        maxlines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.isActive == false)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DefaultTextView(
                            text: S.of(context).hidden,
                            fontSize: 11,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      DefaultTextView(
                        text:
                            '${product.sellingPrice.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}',
                        fontSize: 12,
                        color: Pallete.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      kGap10,
                      if (product.isOffer == true)
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Pallete.orangeColor.withValues(alpha: 0.8),
                            borderRadius: kRadius5,
                          ),
                          child: DefaultTextView(
                            text: S.of(context).offerOnMenu,
                            fontSize: 12,
                            color: Pallete.whiteColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          kGap10,
          // Product image
          if (product.image != null && product.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                product.image!,
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Pallete.greyColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.broken_image,
                    color: Pallete.greyColor,
                    size: 24,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Pallete.greyColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.fastfood,
                color: Pallete.greyColor,
                size: 24,
              ),
            ),
          kGap20,
        ],
      ),
    );
  }
}
