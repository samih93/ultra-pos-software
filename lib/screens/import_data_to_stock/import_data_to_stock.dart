import 'dart:io';
import 'dart:typed_data';

import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/import_data_to_stock/header_table_products.dart';
import 'package:desktoppossystem/screens/import_data_to_stock/import_data_controller.dart';
import 'package:desktoppossystem/screens/import_data_to_stock/stock_row_item.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/stock_screen/components/select_category_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/app_bar_title.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportDataToStockScreen extends ConsumerWidget {
  const ImportDataToStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var importController = ref.watch(importDataControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: S.of(context).importData),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.invalidate(importDataControllerProvider);
            context.pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Center(
                        child: DefaultTextView(
                          text: S.of(context).selectCategory,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SizedBox(
                        width: 400,
                        child: SearchAndSelectCategory(
                          showAddButton: true,
                          onSelected: (c) async {
                            importController.onSelectCategory(c).then((value) {
                              context.pop();
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (importController.selectedCategory == null)
                        Expanded(
                          child: ListTile(
                            title: DefaultTextView(
                              text: S.of(context).selectCategory,
                            ),
                            trailing: const Icon(
                              Icons.arrow_drop_down_circle_outlined,
                            ),
                          ),
                        ),
                      if (importController.selectedCategory != null)
                        Expanded(
                          child: ColoredBox(
                            color: context.primaryColor.withValues(alpha: 0.3),
                            child: ListTile(
                              // dense: true,
                              tileColor: Colors.white,
                              trailing: IconButton(
                                tooltip: S.of(context).clearCateogry,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  ref
                                      .read(importDataControllerProvider)
                                      .clearCategory();
                                },
                              ),
                              title: DefaultTextView(
                                textAlign:
                                    ref.watch(mainControllerProvider).isLtr
                                    ? TextAlign.left
                                    : TextAlign.right,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                text:
                                    "${S.of(context).category} : ${importController.selectedCategory?.name}",
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              kGap20,
              Row(
                children: [
                  ElevatedButtonWidget(
                    text: S.of(context).template,
                    onPressed: () async {
                      await ref
                          .read(globalControllerProvider)
                          .generateImportExcelTemplate();
                    },
                    width: 80,
                    height: 55,
                  ),
                  kGap10,
                  if (importController.selectedCategory != null)
                    ElevatedButtonWidget(
                      states: [importController.readExcelRequestState],
                      text: S.of(context).upload,
                      onPressed: () async {
                        FilePickerResult? pickedFile = await FilePicker.platform
                            .pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['xlsx'],
                              allowMultiple: false,
                            );
                        if (pickedFile != null) {
                          File file = File(pickedFile.files[0].path!);
                          Uint8List fileBytes = await file.readAsBytes();

                          // var bytes =
                          //     pickedFile.files.first.bytes;
                          final List<int> byteList = fileBytes.cast<int>();

                          await importController.readExcelProducts(byteList);
                        }
                      },
                      height: 55,
                    ),
                  kGap10,
                  if (importController.products.isNotEmpty &&
                      importController.selectedCategory != null) ...[
                    DefaultTextView(
                      text:
                          "${importController.products.length} ${S.of(context).products} ${S.of(context).readyToImport}",
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    kGap10,
                    ElevatedButtonWidget(
                      text: S.of(context).import,
                      onPressed: () async {
                        await ref
                            .read(importDataControllerProvider)
                            .addProducts(context);
                      },
                      width: 100,
                      height: 55,
                    ),
                  ],
                ],
              ),
            ],
          ),
          kGap10,
          if (importController.products.isNotEmpty) ...[
            buildHeader(),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    productRowItem(importController.products[index], index),
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.grey),
                itemCount: importController.products.length,
              ),
            ),
          ],
        ],
      ).baseContainer(context.cardColor),
    );
  }
}
