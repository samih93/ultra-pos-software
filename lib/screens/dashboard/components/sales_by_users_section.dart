import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/reports/daily_sale_model.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SalesByUsersSection extends ConsumerWidget {
  const SalesByUsersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureSalesByUsers = ref.watch(futureSalesByUserProvider);
    return futureSalesByUsers.when(
      data: (data) {
        final double totalSales = data.fold(0, (sum, e) => sum + e.amount);
        Widget widget = Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Pallete.greyColor),
          ),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).salesByUsers,
                        style: const TextStyle(fontSize: 18),
                      ),
                      AppPriceText(
                        fontWeight: FontWeight.bold,
                        color: Pallete.redColor,
                        text: " ${totalSales.formatDouble()}",
                        unit: AppConstance.primaryCurrency
                            .currencyLocalization(),
                      ),
                    ],
                  ),
                ),
              ),
              kGap10,
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var salesByUser = data[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        child: Text((index + 1).toString()),
                      ),
                      title: Text(salesByUser.userName),
                      trailing: Text(
                        '${salesByUser.amount.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
        return Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            widget,
            IconButton(
              onPressed: () {
                openWidgetInLargeDialog(context, widget);
              },
              icon: const Icon(Icons.expand),
            ),
          ],
        );
      },
      error: (error, stackTrace) =>
          ErrorSection(retry: () => ref.refresh(futureSalesByUserProvider)),
      loading: () {
        return Skeletonizer(
          enabled: true,
          child: ListView.separated(
            itemCount: 10,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              var salesByUser = SalesByUserModel.fake();
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  child: Text((index + 1).toString()),
                ),
                title: Text(salesByUser.userName),
                trailing: Text(
                  '${salesByUser.amount.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}',
                ),
              );
            },
          ),
        );
      },
    );
  }
}
