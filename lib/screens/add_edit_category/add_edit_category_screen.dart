import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/screens/add_edit_category/add_edit_category_controller.dart';
import 'package:desktoppossystem/screens/add_edit_category/components/category_form.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/categories/components/category_item.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final CategoryModel? c;
  const AddEditCategoryScreen(this.c, {super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  late TextEditingController notetextController;

  @override
  void initState() {
    super.initState();
    ref.read(addEditCategoryControllerProvider).onsetCategory(widget.c);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //! this not a liseter just nedded to call method and read variable
    var categoryController = ref.read(categoryControllerProvider);
    var controller = ref.watch(addEditCategoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          widget.c != null
              ? "${S.of(context).edit} ${widget.c!.name}"
              : S.of(context).addCategoryButton,
        ),
        actions: [
          AppSquaredOutlinedButton(
            states: [ref.watch(categoryControllerProvider).requestState],
            backgroundColor: Pallete.whiteColor,
            onPressed: () async {
              if (controller.formkey.currentState!.validate()) {
                controller.categoryModel!.name =
                    controller.categoryNameController.text;
                controller.categoryModel!.sort =
                    categoryController.categories.length;

                if (controller.categoryModel?.id != null) {
                  categoryController.updateCategory(
                    controller.categoryModel!,
                    context,
                  );
                } else {
                  categoryController.addCategory(
                    controller.categoryModel!,
                    context,
                  );
                }
              } else {}
            },
            child: const Icon(FontAwesomeIcons.floppyDisk, size: 20),
          ),
          kGap10,
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              width: context.width * 0.4,
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  const SizedBox(height: 20),
                  CategoryForm(widget.c),
                  kGap20,

                  if (ref.read(mainControllerProvider).screenUI ==
                      ScreenUI.restaurant) ...[
                    const DefaultTextView(text: "for orders , select section"),
                    kGap5,
                    Container(
                      decoration: BoxDecoration(
                        color: Pallete.coreMistColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...SectionType.values.map((view) {
                            final isSelected =
                                controller.selectedSection == view;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 1,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () {
                                  controller.onchangeSection(view);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Pallete.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    view.sectionTypeToString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                children: [
                  CategoryItem(
                    width: 120,
                    height: 80,
                    controller.categoryModel!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ).baseContainer(context.cardColor),
    );
  }
}
