import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/change_selling_dialog.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/short_toast_message.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketBasketItem extends ConsumerWidget {
  final ProductModel p;
  const MarketBasketItem(this.p, this.index, {Key? key}) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLowStock =
        p.isTracked == true &&
        p.qtyInStock != null &&
        p.qtyInStock! <= p.warningAlert! &&
        p.enableNotification == true;
    bool reachMinSelling = p.minSellingPrice == 0
        ? false
        : p.minSellingPrice! > p.costPrice! &&
              p.sellingPrice! <= p.minSellingPrice!
        ? true
        : false;
    return InkWell(
      onTap: () {
        ref.read(saleControllerProvider).onselectProduct(p);
      },
      onLongPress: () async {
        productAlertDialog(context, ref, p, hideDelete: true);
      },
      child: Dismissible(
        movementDuration: const Duration(seconds: 1),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Pallete.redColor,
                Colors.red.shade500,
              ], // Gradient effect
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.centerRight,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete, // Trash can icon
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10), // Spacer between icon and edge
              Text(
                'Delete', // Optional text to describe action
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        onDismissed: (direction) {
          ref
              .read(saleControllerProvider)
              .removeItemFromBasket(context, index: index);
        },
        key: UniqueKey(),
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Container(
              padding: kPadd5,
              decoration: BoxDecoration(
                color: p.selected!
                    ? context.selectedListColor
                    : context.cardColor,
                border: const Border(
                  bottom: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            if (isLowStock) kGap50,
                            Expanded(
                              child: GestureDetector(
                                onDoubleTap: () {
                                  shortToastMessage(
                                    context,
                                    S.of(context).copiedToClipboard,
                                  );

                                  Clipboard.setData(
                                    ClipboardData(text: p.name.toString()),
                                  );
                                },
                                child: DefaultTextView(
                                  maxlines: 2,
                                  textAlign: isEnglishLanguage
                                      ? TextAlign.left
                                      : TextAlign.right,
                                  text: "${p.name}",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: Text("${p.qty}")),
                      Expanded(
                        child: GestureDetector(
                          onDoubleTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => ChangeSellingDialog(p.id!),
                            );
                          },
                          child: Text(
                            style: TextStyle(
                              color: reachMinSelling ? Pallete.redColor : null,
                            ),
                            "${p.sellingPrice!.toString().length > 3 ? p.sellingPrice!.formatDouble() : p.sellingPrice!.formatDouble()}",
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${(p.qty! * p.sellingPrice!).formatDouble()}",
                        ),
                      ),
                      Expanded(
                        child: DefaultTextView(
                          text: "${p.qtyInStock}",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (p.barcode != null && p.barcode!.isNotEmpty)
                        Row(
                          children: [
                            GestureDetector(
                              onDoubleTap: () async {
                                shortToastMessage(
                                  context,
                                  S.of(context).copiedToClipboard,
                                );

                                Clipboard.setData(
                                  ClipboardData(text: p.barcode.toString()),
                                );
                              },
                              child: DefaultTextView(
                                text: p.barcode!,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            kGap10,
                          ],
                        ),
                      if (isLowStock) ...[
                        Container(
                          padding: kPaddH10,
                          decoration: BoxDecoration(
                            color: Pallete.redColor.withValues(alpha: 0.2),
                            shape: BoxShape.rectangle,
                            borderRadius: kRadius8,
                            border: Border.all(color: Pallete.redColor),
                          ),
                          child: const DefaultTextView(
                            fontWeight: FontWeight.w500,
                            text: "limited stock",
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (p.discount != null && p.discount! > 0)
              DefaultTextView(
                color: Pallete.redColor,
                text: "${p.discount} %",
                fontWeight: FontWeight.bold,
              ),
          ],
        ),
      ),
    );
  }
}
