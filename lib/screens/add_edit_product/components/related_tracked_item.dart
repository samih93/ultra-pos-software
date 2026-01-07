import 'package:desktoppossystem/models/tracked_related_product.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RelatedTrackedItem extends ConsumerWidget {
  const RelatedTrackedItem(this.trackedRelatedProduct, {super.key});

  final TrackedRelatedProductModel trackedRelatedProduct;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: kPaddH8,
      decoration: BoxDecoration(
          borderRadius: kRadius5, gradient: myblueLinearGradient()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTextView(
              text: trackedRelatedProduct.relatedProductName,
              color: Colors.white),
          kGap15,
          DefaultTextView(
              text: "(${trackedRelatedProduct.qtyFromRelatedProduct})",
              color: Colors.white),
          kGap15,
          IconButton(
              onPressed: () {
                ref
                    .read(addEditProductControllerProvider)
                    .removeTrackedRelatedProduct(
                        trackedRelatedProduct.relatedProductId);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ))
        ],
      ),
    );
  }
}
