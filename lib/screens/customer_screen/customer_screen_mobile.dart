import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/screens/customer_screen/components/customer_card_mobile.dart';
import 'package:desktoppossystem/screens/customer_screen/components/customer_header_mobile.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerScreenMobile extends ConsumerStatefulWidget {
  const CustomerScreenMobile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomerScreenMobileState();
}

class _CustomerScreenMobileState extends ConsumerState<CustomerScreenMobile> {
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
    return Column(
      children: [
        const CustomerHeaderMobile(),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              var customerController = ref.watch(customerControllerProvider);

              return Column(
                children: [
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: MyCustomScrollBehavior(),
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: kPadd15,
                        itemCount: customerController.customers.length,
                        separatorBuilder: (context, index) => kGap10,
                        itemBuilder: (context, index) {
                          return CustomerCardMobile(
                            customerController.customers[index],
                          );
                        },
                      ),
                    ),
                  ),
                  if (customerController.fetchCustomerByBatchRequestState ==
                      RequestState.loading)
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: CoreCircularIndicator(),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    ).baseContainer(context.cardColor);
  }
}
