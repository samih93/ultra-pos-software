import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/add_edit_category/add_edit_category_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/categories/components/category_item.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_title_section.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../main_screen.dart/main_controller.dart';
import '../categories_setting_screen.dart';
import '../cateogries_settings_controller.dart';

class Categories extends ConsumerWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var categoryController = ref.watch(categoryControllerProvider);

    if (categoryController.getCategoriesRequestState == RequestState.loading) {
      return const Center(
        child: CoreCircularIndicator(height: 60, coloredLogo: true),
      );
    }
    return Container(
      margin: kPaddH5,
      padding: defaultPadding,
      decoration: BoxDecoration(
        borderRadius: defaultRadius,
        color: context.cardColor,
        border: Border.all(color: Pallete.greyColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppTextTitleSection(S.of(context).categories),
              kGap10,
              const Spacer(),
              Row(
                spacing: 10,
                children: [
                  AppSquaredOutlinedButton(
                    child: const Icon(Icons.settings),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => CategoriesSettingScreen(),
                      );
                    },
                  ),
                  if (ref.watch(mainControllerProvider).isAdmin)
                    AppSquaredOutlinedButton(
                      child: const Icon(Icons.add),
                      onPressed: () {
                        context.to(const AddEditCategoryScreen(null));
                      },
                    ),
                ],
              ),
            ],
          ),
          Container(
            padding: kPadd3,
            height: ref
                .watch(categoriesSettingsControllerProvider)
                .categoriesSectionHeight,
            child: ScrollConfiguration(
              behavior: MyCustomScrollBehavior(),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //     childAspectRatio: 0.6,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  mainAxisExtent: ref
                      .watch(categoriesSettingsControllerProvider)
                      .categoryWidth,
                  crossAxisCount: ref
                      .watch(categoriesSettingsControllerProvider)
                      .nbOfLines,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) {
                  categoryController.categories.sort(
                    (a, b) => a.sort!.compareTo(b.sort!),
                  );
                  return CategoryItem(
                    key: Key(
                      categoryController.categories[index].id.toString(),
                    ),
                    categoryController.categories[index],
                  );
                },
                itemCount: categoryController.categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
