import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DownloadStockButton extends ConsumerWidget {
  const DownloadStockButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedStockCategoryProvider);
    final stockController = ref.watch(stockControllerProvider);
    return Tooltip(
      message: selectedCategory != null
          ? S.of(context).downloadStockByCategory
          : S.of(context).downloadAllStock,
      child: AppSquaredOutlinedButton(
        states: [
          stockController.getDownloadStockRequestState,
          ref.watch(globalControllerProvider).openDailySaleExcelRequestState,
        ],
        onPressed: () async {
          await downloadStock(ref);
        },
        child: const Icon(
          FontAwesomeIcons.fileExcel,
          color: Pallete.greenColor,
        ),
      ),
    );
  }

  Future<void> downloadStock(WidgetRef ref) async {
    await ref.read(stockControllerProvider).getAllStock().then((
      products,
    ) async {
      await ref.read(globalControllerProvider).openStockInExcel(products);
    });
  }
}
