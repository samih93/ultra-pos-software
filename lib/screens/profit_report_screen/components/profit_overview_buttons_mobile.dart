import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/view_model/profit_report_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button_new.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfitOverviewButtonsMobile extends ConsumerWidget {
  ProfitOverviewButtonsMobile({super.key});
  final List<ReportInterval> views = [
    ReportInterval.daily,
    ReportInterval.monthly,
    ReportInterval.yearly,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.watch(profitControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle buttons and PDF download
        Row(
          children: [
            // Toggle buttons
            Expanded(
              child: Center(
                child: CustomToggleButtonNew(
                  labels: views
                      .map((view) => view.localizedName(context))
                      .toList(),
                  selectedIndex: views.indexOf(controller.selectedView),
                  onPressed: (index) {
                    controller.onchangeView(views[index], context);
                  },
                  height: 40,
                ),
              ),
            ),
            kGap10,
            // PDF Download button
            if (controller.selectedView != ReportInterval.yearly)
              AppSquaredOutlinedButton(
                states: [
                  ref
                      .watch(globalControllerProvider)
                      .downloadProfitReportRequestState,
                ],
                onPressed: () async {
                  final mainController = ref.read(mainControllerProvider);

                  String header =
                      "${S.of(context).profitReport} ( ${controller.displaySelectedViewAndDate} ) => ${controller.finalProfit.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}";
                  ProfitReportModel model = ProfitReportModel(
                    header: header,
                    expenses: controller.expensesList,
                    totalExpenses: controller.totalExpenses,
                    totalCost: controller.totalCost,
                    totalPaid: controller.totalPaid,
                    profit: controller.totalProfit,
                    products: controller.salesProductList,
                    restaurantCost: mainController.isWorkWithIngredients == true
                        ? controller.restaurantTotalCost
                        : null,
                    stockUsageList: mainController.isWorkWithIngredients == true
                        ? controller.stockUsageList
                        : null,
                    wasteList: mainController.isWorkWithIngredients == true
                        ? controller.wasteList
                        : null,
                    totalWaste: controller.totalWaste,
                    subscriptionsStats: mainController.subscriptionActivated
                        ? controller.subscriptionStatsList
                        : [],
                    totalSubscriptionIncome: controller.totalSubscriptionIncome,
                  );
                  await ref
                      .read(globalControllerProvider)
                      .downloadProfitReport(model);
                },
                child: const Icon(
                  FontAwesomeIcons.filePdf,
                  color: Pallete.redColor,
                ),
              ),
          ],
        ),
        kGap5,

        // Search field
        AppTextFormField(
          prefixIcon: const Icon(Icons.search, color: Pallete.greyColor),
          onfieldsubmit: (value) {
            ref
                .read(profitControllerProvider)
                .onSearchInProfit(value.toString());
          },
          onchange: (value) {
            ref
                .read(profitControllerProvider)
                .onSearchInProfit(value.toString());
          },
          border: OutlineInputBorder(
            borderSide: BorderSide(color: context.primaryColor),
          ),
          inputtype: TextInputType.name,
          hinttext: S.of(context).searchByNameOrBarcode,
        ),
        kGap5,

        // Profit card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Pallete.greenColor.withValues(alpha: 0.1),
            shape: BoxShape.rectangle,
            borderRadius: kRadius8,
            border: Border.all(color: Pallete.greenColor),
          ),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.dollarSign,
                size: 20.spMax,
                color: Pallete.greenColor,
              ),
              kGap10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextView(
                      text:
                          "${S.of(context).profit} (${controller.displaySelectedViewAndDate})",
                      fontSize: 12.spMax,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    DefaultTextView(
                      text: controller.finalProfit.formatDouble().toString(),
                      fontSize: 16.spMax,
                      fontWeight: FontWeight.bold,
                      color: Pallete.greenColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
