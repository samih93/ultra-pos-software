import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_settings_controller.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DownloadWeightedProductsButton extends ConsumerWidget {
  const DownloadWeightedProductsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingController = ref.watch(productsSettingsControllerProvider);
    return settingController.isUsingScale
        ? Row(
            children: [
              ElevatedButtonWidget(
                text: "Weighted products",
                icon: FontAwesomeIcons.fileExcel,
                color: Pallete.greenColor,
                onPressed: () async {
                  await ref
                      .read(globalControllerProvider)
                      .openWeightedStockInExcel();
                },
                states: [
                  ref
                      .watch(globalControllerProvider)
                      .openStockInExcelRequestState
                ],
              ),
              kGap5,
            ],
          )
        : kEmptyWidget;
  }
}
