import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/screens/customer_screen/components/customer_hedear.dart';
import 'package:desktoppossystem/screens/customer_screen/components/customer_item.dart';
import 'package:desktoppossystem/screens/customer_screen/components/customer_table_header.dart';
import 'package:desktoppossystem/screens/customer_screen/customer_screen_mobile.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref.read(customerControllerProvider).fetchCustomersByBatch();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobileView: const CustomerScreenMobile(),
      desktopView: _buildDesktopView(context),
    );
  }

  Widget _buildDesktopView(BuildContext context) {
    return Column(
      children: [
        const CustomerHedear(),
        const CustomerTableHeader(),
        Divider(color: context.primaryColor),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              var customerController = ref.watch(customerControllerProvider);

              return Column(
                children: [
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: MyCustomScrollBehavior(),
                      child: CustomScrollView(
                        controller: _scrollController,
                        cacheExtent: 40,
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return CustomerItem(
                                customerController.customers[index],
                              );
                            }, childCount: customerController.customers.length),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (customerController.fetchCustomerByBatchRequestState ==
                      RequestState.loading)
                    const CoreCircularIndicator(),
                ],
              );
            },
          ),
        ),
      ],
    ).baseContainer(context.cardColor);
  }
}
