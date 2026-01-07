import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/mobile/components/category_item_mobile.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoriesMobile extends ConsumerWidget {
  const CategoriesMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var categoryController = ref.watch(categoryControllerProvider);

    if (categoryController.getCategoriesRequestState == RequestState.loading) {
      return const Center(
        child: CoreCircularIndicator(height: 40, coloredLogo: true),
      );
    }

    // Sort categories
    final sortedCategories = [...categoryController.categories]
      ..sort((a, b) => a.sort!.compareTo(b.sort!));

    return GridView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 100,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.5,
      ),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        return CategoryItemMobile(
          sortedCategories[index],
          key: Key(sortedCategories[index].id.toString()),
        );
      },
    );
  }
}
