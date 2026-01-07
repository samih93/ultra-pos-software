import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/reports/daily_sale_model.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/components/customer_receipt_list.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/invoices_by_customer_screen.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Top10CustomersSection extends ConsumerWidget {
  const Top10CustomersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var futureCutomer = ref.watch(futureTop10Customers);
    return futureCutomer.when(
      data: (data) {
        Widget widget = Container(
          decoration: BoxDecoration(
            // borderRadius: defaultRadius,
            border: Border.all(width: 1, color: Pallete.greyColor),
          ),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '🏆 ${S.of(context).top10SpendingCustomers}',
                    style: const TextStyle(fontSize: 18),
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
                    var customer = data[index];
                    return ListTile(
                      dense: true,
                      onTap: () {
                        ref.refresh(topSellingProductProvider(customer.id!));
                        ref.refresh(
                          invoicesByCustomerProvider(
                            ReceiptRequest(
                              customerId: customer.id!,
                              status: ref.read(selectedReceiptStatusProvider),
                            ),
                          ),
                        );
                        ref.refresh(
                          revenuAndProfitByCustomerProvider(customer.id!),
                        );
                        context.to(
                          InvoicesByCustomerScreen(customer: customer),
                        );
                      },
                      leading: CircleAvatar(
                        radius: 16,
                        child: Text((index + 1).toString()),
                      ),
                      title: Text("${customer.name}"),
                      subtitle: Text("${customer.phoneNumber}"),
                      trailing: Text(
                        '${customer.totalPurchases.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}',
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
          ErrorSection(retry: () => ref.refresh(futureTop10Customers)),
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
