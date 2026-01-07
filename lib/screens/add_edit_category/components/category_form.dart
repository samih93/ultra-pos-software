import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/screens/add_edit_category/add_edit_category_controller.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryForm extends ConsumerWidget {
  final CategoryModel? c;
  const CategoryForm(this.c, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.watch(addEditCategoryControllerProvider);

    return Form(
      key: controller.formkey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AppTextFormField(
              showText: true,
              inputtype: TextInputType.name,
              controller: controller.categoryNameController,
              hinttext: S.of(context).name,
              onchange: (value) {
                controller.onchangeFieldName(value);
              },
              onvalidate: (value) {
                if (value!.isEmpty) {
                  return S.of(context).nameMustBeNotEmpty;
                }
                return null;
              },
            ),
          ),
          kGap10,
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: DefaultTextView(
                        text: S.of(context).selectColor, color: Colors.black),
                    content: SizedBox(
                      width: 300,
                      child: MaterialColorPicker(
                        alignment: WrapAlignment.center,
                        onColorChange: (Color color) {
                          controller.onchangeBackroundColor(color);
                        },
                        selectedColor: controller.selectedBackgroundColor,
                        colors: [
                          Pallete.orangeColor.createMaterialColor(),
                          Pallete.redColor.createMaterialColor(),
                          Pallete.greenColor.createMaterialColor(),
                          Pallete.yellowColor.createMaterialColor(),
                          Pallete.blueColor.createMaterialColor(),
                          Pallete.purpleColor.createMaterialColor(),
                          Pallete.primaryColor.createMaterialColor(),
                          Colors.grey,
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text(S.of(context).save),
                        onPressed: () {
                          //! setState(
                          //!     () => currentColor = pickerColor);
                          context.pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              width: 100,
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: kRadius15,
                  color: controller.categoryModel?.color != null
                      ? controller.categoryModel!.color!.getColorFromHex()
                      : Colors.red,
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
