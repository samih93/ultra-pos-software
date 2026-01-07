import 'package:desktoppossystem/controller/supplier_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/suppliers_screen/components/supplier_hedear.dart';
import 'package:desktoppossystem/screens/suppliers_screen/components/supplier_item.dart';
import 'package:desktoppossystem/screens/suppliers_screen/components/supplier_table_header.dart';
import 'package:desktoppossystem/shared/default%20components/app_bar_title.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<SuppliersScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref.read(supplierControllerProvider).fetchSuppliersByBatch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var supplierController = ref.watch(supplierControllerProvider);
    return Scaffold(
      appBar: AppBar(title: AppBarTitle(title: S.of(context).suppliers)),
      body: Column(
        children: [
          const SupplierHedear(),
          const SupplierTableHeader(),
          Divider(color: context.primaryColor),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              cacheExtent: 40,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return SupplierItem(supplierController.suppliers[index]);
                  }, childCount: supplierController.suppliers.length),
                ),
              ],
            ),
          ),
          if (supplierController.fetchSuppliersByBatchRequestState ==
              RequestState.loading)
            const Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: CoreCircularIndicator(),
              ),
            ),
        ],
      ).baseContainer(context.cardColor),
    );
  }
}
