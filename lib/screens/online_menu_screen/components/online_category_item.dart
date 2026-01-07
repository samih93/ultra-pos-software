import 'package:desktoppossystem/controller/menu_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/screens/online_menu_screen/sub_sreens/add_edit_menu_category_screen.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnlineCategoryItem extends ConsumerWidget {
  final CategoryModel category;
  final double? width;
  final double? height;
  final bool isListView;

  const OnlineCategoryItem(
    this.category, {
    this.width,
    this.height,
    this.isListView = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuController = ref.watch(menuControllerProvider);
    final isSelected = menuController.selectedCategory?.id == category.id;

    return InkWell(
      onTap: () {
        // Fetch products when category is clicked
        ref.read(menuControllerProvider.notifier).selectCategory(category);
      },
      onDoubleTap: () {
        context.to(AddEditMenuCategoryScreen(category));
      },
      child: Container(
        width: isListView ? null : (width ?? 100),
        height: isListView ? 60 : (height ?? 100),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Pallete.primaryColor : Pallete.greyColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Pallete.primaryColor.withValues(alpha: 0.05)
              : context.cardColor,
        ),
        child: isListView
            ? Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextView(
                          text: category.name ?? '',
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? Pallete.primaryColor : null,
                        ),
                        const SizedBox(height: 2),
                        DefaultTextView(
                          text:
                              '${category.productsCount ?? 0} ${S.of(context).items}',
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ),
                  if (category.hideOnMenu == true)
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
                  const SizedBox(width: 8),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category,
                    size: 35,
                    color: isSelected
                        ? Pallete.primaryColor
                        : Pallete.greyColor,
                  ),
                  const SizedBox(height: 5),
                  DefaultTextView(
                    text: category.name ?? '',
                    fontSize: 12,
                    maxlines: 2,
                    textAlign: TextAlign.center,
                    color: isSelected ? Pallete.primaryColor : null,
                  ),
                ],
              ),
      ),
    );
  }
}
