import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/view_model/profit_report_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/profit_report_screen/components/profit_overview_buttons_mobile.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfitOverviewButtons extends ConsumerWidget {
  ProfitOverviewButtons({super.key});
  final List<ReportInterval> views = [
    ReportInterval.daily,
    ReportInterval.monthly,
    ReportInterval.yearly,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.watch(profitControllerProvider);

    return ResponsiveWidget(
      mobileView: ProfitOverviewButtonsMobile(),
      desktopView: _buildDesktopView(context, ref, controller),
    );
  }

  Widget _buildDesktopView(
    BuildContext context,
    WidgetRef ref,
    ProfitController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 140, maxWidth: 250),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 140,
              minHeight: 45,
              maxHeight: 50,
            ),
            padding: kPaddH5,
            decoration: BoxDecoration(
              color: Pallete.greenColor.withValues(alpha: 0.1),
              shape: BoxShape.rectangle,
              borderRadius: kRadius8,
              border: Border.all(color: Pallete.greenColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.monetization_on,
                  size: context.bodySize,
                  color: Pallete.greenColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      DefaultTextView(
                        text:
                            "${S.of(context).profit}(${controller.displaySelectedViewAndDate})",
                        fontSize: context.smallSize,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      DefaultTextView(
                        text: "${controller.finalProfit.formatDouble()}",
                        fontSize: context.smallSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: .start,
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Pallete.coreMist50Color,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...views.map((view) {
                      final isSelected = controller.selectedView == view;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            controller.onchangeView(view, context);
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
                              view.localizedName(context),
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
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
              const Spacer(),
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 300,
                    child: AppTextFormField(
                      autofocus: false,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Pallete.greyColor,
                      ),
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
                  ),
                  if (controller.selectedView != ReportInterval.yearly)
                    AppSquaredOutlinedButton(
                      size: const Size(42, 42),
                      //text: S.of(context).download,
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
                          restaurantCost:
                              mainController.isWorkWithIngredients == true
                              ? controller.restaurantTotalCost
                              : null,
                          stockUsageList:
                              mainController.isWorkWithIngredients == true
                              ? controller.stockUsageList
                              : null,
                          wasteList:
                              mainController.isWorkWithIngredients == true
                              ? controller.wasteList
                              : null,
                          totalWaste: controller.totalWaste,
                          subscriptionsStats:
                              mainController.subscriptionActivated
                              ? controller.subscriptionStatsList
                              : [],
                          totalSubscriptionIncome:
                              controller.totalSubscriptionIncome,
                        );

                        await ref
                            .read(globalControllerProvider)
                            .downloadProfitReport(model);
                      },
                      //text: S.of(context).download,
                      child: const Icon(
                        FontAwesomeIcons.filePdf,
                        color: Pallete.redColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
