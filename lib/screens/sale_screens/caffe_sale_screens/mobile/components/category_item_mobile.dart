import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryItemMobile extends ConsumerWidget {
  const CategoryItemMobile(this.category, {super.key});

  final CategoryModel category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryController = ref.watch(categoryControllerProvider);
    final productController = ref.read(productControllerProvider);

    final isSelected = categoryController.selectedCategory?.id == category.id;
    final categoryColor = Color(
      category.color != null ? int.parse(category.color!) : 0xFF0000,
    );

    return GestureDetector(
      onTap: () {
        productController.onselectcategory(category);
        categoryController.onselectcategory(category);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? categoryColor
              : categoryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? categoryColor
                : categoryColor.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: DefaultTextView(
            text: category.name.validateString(),
            fontSize: 13.spMax,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : context.brightnessColor,
            maxlines: 1,
          ),
        ),
      ),
    );
  }
}
