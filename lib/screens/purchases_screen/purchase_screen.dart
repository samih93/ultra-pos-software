import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/purchases_screen/components/purchases_section.dart';
import 'package:desktoppossystem/screens/purchases_screen/components/new_purchase_section.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<PurchaseScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Column(children: [
          SizedBox(
            height: 52,
            child: TabBar(
              dividerColor: Pallete.greyColor,
              labelPadding: EdgeInsets.zero,
              labelColor: context.primaryColor,
              tabs: [
                Tab(
                  icon: const Icon(Icons.receipt),
                  child: DefaultTextView(
                    text: S.of(context).newPurchase,
                  ),
                ),
                Tab(
                  icon: const Icon(
                    Icons.list,
                  ),
                  child: DefaultTextView(
                    text: S.of(context).purchases,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                NewPurchaseSection(),
                PurchasesSection(),
              ],
            ),
          ),
        ])).baseContainer(context.cardColor);
  }
}
