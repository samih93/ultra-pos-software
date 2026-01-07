import 'dart:io';
import 'dart:typed_data';

import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/import%20customers/customer_row_item.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/import%20customers/header_import_customers.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/import%20customers/import_customer_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_bar_title.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportCustomersScreen extends ConsumerWidget {
  const ImportCustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var importCustomerController = ref.watch(importCustomerControllerProvider);

    return Scaffold(
      appBar: AppBar(title: AppBarTitle(title: S.of(context).importCustomers)),
      body: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (importCustomerController.customers.isNotEmpty) ...[
                DefaultTextView(
                  text:
                      "${importCustomerController.customers.length} ${S.of(context).customers} ${S.of(context).readyToImport}",
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                AppSquaredOutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(importCustomerControllerProvider)
                        .addCustomers(context);
                  },
                  size: const Size(70, 38),
                  child: DefaultTextView(text: S.of(context).import),
                ),
              ],
              AppSquaredOutlinedButton(
                size: const Size(70, 38),
                onPressed: () async {
                  await ref
                      .read(globalControllerProvider)
                      .generateCustomerExcelTemplate();
                },
                child: DefaultTextView(
                  text: S.of(context).template,
                  color: Pallete.blackColor,
                ),
              ),
              AppSquaredOutlinedButton(
                size: const Size(70, 38),
                states: [importCustomerController.readExcelRequestState],
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

                    await importCustomerController.readExcelProducts(byteList);
                  }
                },
                child: DefaultTextView(
                  text: S.of(context).upload,
                  color: Pallete.blackColor,
                ),
              ),
              kGap10,
            ],
          ),
          if (importCustomerController.customers.isNotEmpty) ...[
            buildImportCustomerHeader(context),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) => customerRowItem(
                  importCustomerController.customers[index],
                  index,
                ),
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.grey),
                itemCount: importCustomerController.customers.length,
              ),
            ),
          ],
        ],
      ).baseContainer(context.cardColor),
    );
  }
}
