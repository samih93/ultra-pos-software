import 'package:desktoppossystem/controller/menu_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/screens/online_menu_screen/sub_sreens/add_edit_menu_category_screen.dart';
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
import 'package:flutter_slidable/flutter_slidable.dart';

import 'online_category_item.dart';

class OnlineCategories extends ConsumerWidget {
  const OnlineCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var menuController = ref.watch(menuControllerProvider);

    if (menuController.getAllCategoriesState == RequestState.loading) {
      return const Center(
        child: CoreCircularIndicator(height: 60, coloredLogo: true),
      );
    }

    // Sort categories by sort field
    final categories = List<CategoryModel>.from(menuController.categories)
      ..sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));

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
                    child: const Icon(Icons.refresh),
                    onPressed: () async {
                      await ref
                          .read(menuControllerProvider.notifier)
                          .getAllCategories();
                    },
                  ),
                  AppSquaredOutlinedButton(
                    child: const Icon(Icons.add),
                    onPressed: () {
                      context.to(const AddEditMenuCategoryScreen(null));
                    },
                  ),
                ],
              ),
            ],
          ),
          kGap10,
          Expanded(
            child: ScrollConfiguration(
              behavior: MyCustomScrollBehavior(),
              child: ReorderableListView.builder(
                buildDefaultDragHandles: true,
                itemCount: categories.length,
                onReorder: (oldIndex, newIndex) {
                  // Update sort order locally first
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }

                  // Create a new list with updated order
                  final reorderedCategories = List<CategoryModel>.from(
                    categories,
                  );
                  final item = reorderedCategories.removeAt(oldIndex);
                  reorderedCategories.insert(newIndex, item);

                  // Update all sort values
                  for (int i = 0; i < reorderedCategories.length; i++) {
                    reorderedCategories[i].sort = i;
                  }

                  // Then sync to server
                  ref
                      .read(menuControllerProvider.notifier)
                      .syncCategoryOrder(reorderedCategories);
                },
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Container(
                    key: ValueKey('online_category_${category.id}_$index'),
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            spacing: 0,
                            padding: const EdgeInsets.all(1),
                            onPressed: (_) {
                              ref
                                  .read(menuControllerProvider.notifier)
                                  .deleteCategory(category.id!);
                            },
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                        ],
                      ),
                      child: OnlineCategoryItem(category, isListView: true),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
