import 'package:desktoppossystem/controller/menu_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddEditMenuCategoryScreen extends ConsumerStatefulWidget {
  final CategoryModel? category;
  const AddEditMenuCategoryScreen(this.category, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddEditMenuCategoryScreenState();
}

class _AddEditMenuCategoryScreenState
    extends ConsumerState<AddEditMenuCategoryScreen> {
  late TextEditingController categoryNameController;
  late CategoryModel categoryModel;
  final formKey = GlobalKey<FormState>();
  bool hideOnMenu = false;

  @override
  void initState() {
    super.initState();
    categoryNameController = TextEditingController();

    if (widget.category != null) {
      // Update mode
      categoryModel = widget.category!;
      categoryNameController.text = categoryModel.name ?? '';
      hideOnMenu = categoryModel.hideOnMenu ?? false;
    } else {
      // Add mode
      categoryModel = CategoryModel.second();
    }
  }

  void toggleHideOnMenu() {
    setState(() {
      hideOnMenu = !hideOnMenu;
      categoryModel.hideOnMenu = hideOnMenu;
    });
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuController = ref.watch(menuControllerProvider);
    final isUpdate = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: DefaultTextView(
          text: isUpdate
              ? "${S.of(context).edit} ${widget.category!.name}"
              : S.of(context).addCategoryButton,
        ),
        actions: [
          AppSquaredOutlinedButton(
            states: [
              isUpdate
                  ? menuController.updateCategoryState
                  : menuController.createCategoryState,
            ],
            backgroundColor: Pallete.whiteColor,
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                categoryModel.name = categoryNameController.text;
                categoryModel.hideOnMenu = hideOnMenu;

                if (isUpdate) {
                  await ref
                      .read(menuControllerProvider.notifier)
                      .updateCategory(categoryModel);
                  if (context.mounted) context.pop();
                } else {
                  await ref
                      .read(menuControllerProvider.notifier)
                      .createCategory(categoryModel);
                  if (context.mounted) context.pop();
                }
              }
            },
            child: const Icon(FontAwesomeIcons.floppyDisk, size: 20),
          ),
          kGap10,
        ],
      ),
      body: Center(
        child: SizedBox(
          width: context.width * 0.6,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kGap20,
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        showText: true,
                        controller: categoryNameController,
                        hinttext: S.of(context).category,
                        onvalidate: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).nameMustBeNotEmpty;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                kGap20,
                Row(
                  children: [
                    Checkbox(
                      value: hideOnMenu,
                      onChanged: (val) {
                        toggleHideOnMenu();
                      },
                    ),
                    DefaultTextView(text: S.of(context).hideOnMenu),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).baseContainer(context.cardColor),
    );
  }
}
