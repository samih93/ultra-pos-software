import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/categories/components/sort_category_item.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeCategorySortDialog extends ConsumerWidget {
  const ChangeCategorySortDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryController = ref.watch(categoryControllerProvider);
    return AlertDialog(
      actions: [
        ElevatedButtonWidget(
          width: double.infinity,
          text: S.of(context).save,
          onPressed: () {
            ref.read(categoryControllerProvider).saveNewCategoriesSort();
            context.pop();
          },
          icon: Icons.save,
        ),
      ],
      title: DefaultTextView(
        textAlign: TextAlign.center,
        fontSize: 16,
        text: S.of(context).changeCategoryOrder,
      ),
      content: SizedBox(
        height: context.height * 0.6,
        width: 300,
        child: Center(
          child: SingleChildScrollView(
            child: ReorderableListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              buildDefaultDragHandles: true,
              onReorder: (int oldIndex, int newIndex) {
                ref
                    .read(categoryControllerProvider)
                    .reSortList(oldIndex, newIndex);
              },
              children: categoryController.categories.map((category) {
                return SortCategoryItem(
                  categoryModel: category,
                  key: ValueKey("sort_${category.id}"),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
