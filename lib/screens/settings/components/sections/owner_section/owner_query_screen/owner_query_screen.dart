import 'dart:ui';

import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/default%20components/app_bar_title.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final queryResultProvider = StateProvider<String?>((ref) {
  return null;
});
final errorResultProvider = StateProvider<String?>((ref) {
  return null;
});

class OwnerQueryScreen extends ConsumerStatefulWidget {
  const OwnerQueryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OwnerQuerySectionState();
}

class _OwnerQuerySectionState extends ConsumerState<OwnerQueryScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var queryResult = ref.watch(queryResultProvider);
    var errorResult = ref.watch(errorResultProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            ref.invalidate(queryResultProvider);
            ref.invalidate(errorResultProvider);
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: myLinearGradient(context)),
        ),
        title: const AppBarTitle(title: "Query Screen"),
      ),
      body: Container(
        padding: kPadd10,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButtonWidget(
                  color: Pallete.greenColor,
                  icon: Icons.check_circle_outline_outlined,
                  text: "Execute",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AreYouSureDialog(
                        "Are you sure you want to proceed",
                        onCancel: () => context.pop(),
                        onAgree: () {
                          ref.invalidate(queryResultProvider);
                          ref.invalidate(errorResultProvider);
                          ref
                              .read(globalControllerProvider)
                              .executeQuery(_controller.text.trim());
                          context.pop();
                        },
                        agreeText: "Yes",
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 5,
                  children: [
                    ElevatedButtonWidget(
                      text: "Clear",
                      onPressed: () {
                        _controller.clear();
                        ref.invalidate(queryResultProvider);
                        ref.invalidate(errorResultProvider);
                      },
                    ),
                    ElevatedButtonWidget(
                      text: "Activate All products",
                      onPressed: () {
                        activateAllProducts();
                      },
                    ),
                    ElevatedButtonWidget(
                      text: "Update low stock warning",
                      onPressed: () {
                        updateLowStockWarning();
                      },
                    ),
                    ElevatedButtonWidget(
                      text: "Receipts count by year",
                      onPressed: () {
                        selectReceiptsCountByYear();
                      },
                    ),
                    ElevatedButtonWidget(
                      text: "Details Receipts count by year",
                      onPressed: () {
                        selectDetailsReceiptsCountByYear();
                      },
                    ),
                    ElevatedButtonWidget(
                      text: "Delete Details Receipts by year",
                      onPressed: () {
                        deleteDetailsReceiptsByYear();
                      },
                    ),
                    ElevatedButtonWidget(
                      text: "Delete Receipts by year",
                      onPressed: () {
                        deleteReceiptsByYear();
                      },
                    ),
                    ElevatedButtonWidget(
                      text: "set min selling",
                      onPressed: () {
                        setMinSelling();
                      },
                    ),
                    ElevatedButtonWidget(
                      text: "set telegram chat id",
                      onPressed: () {
                        setTelegramChatId();
                      },
                    ),
                    kGap5,
                  ],
                ),
              ),
            ),
            kGap10,
            AppTextFormField(
              contentPadding: const EdgeInsets.all(10),
              controller: _controller,
              maxligne: 8,
              minline: 5,
              height: 200,
              hinttext: "Write your sql query",
            ),
            if (queryResult != null)
              Row(children: [Expanded(child: SelectableText(queryResult))]),
            if (errorResult != null)
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      errorResult,
                      style: const TextStyle(color: Pallete.redColor),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void selectReceiptsCountByYear() {
    _controller.text =
        '''SELECT 
                                      CAST(SUBSTR(receiptDate, 1, 4) AS INTEGER) AS year,
                                      COUNT(*) AS receipt_count
                                      FROM ${TableConstant.receiptTable} where CAST(SUBSTR(receiptDate, 1, 4) AS INTEGER)=2024
                                      GROUP BY year
                                      ORDER BY year''';
  }

  void activateAllProducts() {
    _controller.text =
        '''update ${TableConstant.productTable} set isActive =1''';
  }

  void updateLowStockWarning() {
    _controller.text =
        '''update ${TableConstant.productTable} set warningAlert =1''';
  }

  void selectDetailsReceiptsCountByYear() {
    _controller.text =
        '''SELECT count(*)
FROM ${TableConstant.detailsReceiptTable}
WHERE receiptId IN (
  SELECT id FROM ${TableConstant.receiptTable}
  WHERE CAST(SUBSTR(receiptDate, 1, 4) AS INTEGER) = 2024
)''';
  }

  void deleteDetailsReceiptsByYear() {
    _controller.text =
        '''
    DELETE FROM ${TableConstant.detailsReceiptTable}
    WHERE receiptId IN (
      SELECT id FROM ${TableConstant.receiptTable}
      WHERE CAST(SUBSTR(receiptDate, 1, 4) AS INTEGER) = 2024
    )''';
  }

  void deleteReceiptsByYear() {
    _controller.text =
        '''
    DELETE FROM ${TableConstant.receiptTable}
    WHERE CAST(SUBSTR(receiptDate, 1, 4) AS INTEGER) = 2024
  ''';
  }

  void setTelegramChatId() {
    _controller.text = '''update settings set telegramChatId='5069973190' ''';
  }

  void setMinSelling() {
    _controller.text = '''UPDATE products
SET minSellingPrice = ROUND(costPrice * (1 + 0.25), 3)
WHERE costPrice IS NOT NULL;
''';
  }
}
