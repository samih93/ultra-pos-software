import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortProductItem extends ConsumerWidget {
  const SortProductItem({required this.productModel, super.key});

  final ProductModel productModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = productModel.categoryColor ?? Colors.red;
    return Padding(
        padding: kPadd3,
        child: ListTile(
          title: DefaultTextView(
            text: "${productModel.name}",
          ),
        ));
  }
}
