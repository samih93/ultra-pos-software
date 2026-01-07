import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/categories/cateogries_settings_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/categories/components/change_category_sort_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesSettingScreen extends ConsumerWidget {
  CategoriesSettingScreen({super.key});
  final List<double> categoryWidthList = [50, 60, 70, 80, 90, 100, 110];
  final List<int> nbOfLinesList = [1, 2];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.watch(categoriesSettingsControllerProvider);
    return AlertDialog(
      title: Center(child: Text(S.of(context).settingCategory)),
      content: SizedBox(
        width: 270,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: DefaultTextView(
                      textAlign: TextAlign.center,
                      fontSize: 16,
                      text: S.of(context).categoryWidth,
                    ),
                    content: SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            kGap5,
                            ...categoryWidthList.map((e) {
                              return ListTile(
                                trailing:
                                    controller.categoryWidth ==
                                        categoryWidthList[categoryWidthList
                                            .indexOf(e)]
                                    ? Icon(
                                        Icons.check_circle,
                                        color: context.primaryColor,
                                      )
                                    : kEmptyWidget,
                                title: DefaultTextView(text: e.toString()),
                                onTap: () async {
                                  controller.onChangeCategoryWidth(e);

                                  context.pop();
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              title: DefaultTextView(text: S.of(context).categoryWidth),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DefaultTextView(text: controller.categoryWidth.toString()),
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.grey,
                  ),
                ],
              ),
              leading: const Icon(Icons.width_normal, color: Colors.grey),
            ),
            DefaultListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: DefaultTextView(
                      textAlign: TextAlign.center,
                      fontSize: 16,
                      text: "${S.of(context).nbOfLines} ",
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        kGap5,
                        ...nbOfLinesList.map((e) {
                          return ListTile(
                            trailing:
                                controller.nbOfLines ==
                                    nbOfLinesList[nbOfLinesList.indexOf(e)]
                                ? Icon(
                                    Icons.check_circle,
                                    color: context.primaryColor,
                                  )
                                : kEmptyWidget,
                            title: DefaultTextView(text: e.toString()),
                            onTap: () async {
                              controller.onchangeNbOfLine(e);

                              context.pop();
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
              title: DefaultTextView(text: S.of(context).nbOfLines),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DefaultTextView(text: "${controller.nbOfLines}"),
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.grey,
                  ),
                ],
              ),
              leading: const Icon(
                Icons.view_agenda_rounded,
                color: Colors.grey,
              ),
            ),
            if (ref.read(mainControllerProvider).isAdmin)
              DefaultListTile(
                onTap: () {
                  context.pop();
                  showDialog(
                    context: context,
                    builder: (context) => const ChangeCategorySortDialog(),
                  );
                },
                title: DefaultTextView(text: S.of(context).changeCategoryOrder),
                leading: const Icon(Icons.sort_outlined, color: Colors.grey),
                trailing: const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
