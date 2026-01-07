import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortCategoryItem extends ConsumerWidget {
  const SortCategoryItem({required this.categoryModel, super.key});

  final CategoryModel categoryModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = categoryModel.color?.getColorFromHex() ?? Colors.red;
    return Padding(
        padding: kPadd3,
        child: ListTile(
          title: DefaultTextView(
            text: "${categoryModel.name}",
            // color: color.getTextColorBasedOnBackground(),
          ),
        ));
  }
}
