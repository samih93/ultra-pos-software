import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/components/customer_receipt_list.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/components/revenue_and_profit_chart.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/components/top_most_bought_items_pie.dart';
import 'package:desktoppossystem/shared/default%20components/app_bar_title.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvoicesByCustomerScreen extends ConsumerWidget {
  const InvoicesByCustomerScreen({required this.customer, super.key});
  final CustomerModel customer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: AppBarTitle(title: customer.name.validateString())),
      body: Row(
        crossAxisAlignment: .start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: CustomerReceiptList(customer: customer)),
          kGap10,
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: RevenueAndProfitChart(customerId: customer.id!),
                ),
                Expanded(
                  flex: 3,
                  child: TopMostBoughtItemsPie(customerId: customer.id!),
                ),
              ],
            ),
          ),
        ],
      ).baseContainer(context.cardColor),
    );
  }
}
