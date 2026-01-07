import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/notifications_screen/components/expired_stock_tab.dart';
import 'package:desktoppossystem/screens/notifications_screen/components/low_stock_tab.dart';
import 'package:desktoppossystem/screens/notifications_screen/components/pending_receipts_tab.dart';
import 'package:desktoppossystem/screens/notifications_screen/components/zero_stock_tab.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketLowStockNotificationsScreen extends ConsumerStatefulWidget {
  const MarketLowStockNotificationsScreen({super.key});

  @override
  ConsumerState<MarketLowStockNotificationsScreen> createState() =>
      _MarketLowStockNotificationsScreenState();
}

class _MarketLowStockNotificationsScreenState
    extends ConsumerState<MarketLowStockNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the future provider for low stock notifications
    var lowStock = ref.watch(futureMarketLowStockProvider);
    var expiredStock = ref.watch(futureMarketExpiredStockProvider);
    var outOfStock = ref.watch(futureMarketOutOfStockProvider);
    var futurePendingReceipts = ref.watch(futurePendingReceiptsNotification);
    var controller = ref.watch(notificationControllerProvider);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
          title: Text(S.of(context).notifications),
          actions: [
            // Download Low Stock button
            AppSquaredOutlinedButton(
              states: [controller.exportNotificationsRequestState],
              child: const Icon(Icons.download),
              onPressed: () {
                // Get the current tab index from our controller
                final currentIndex = _tabController.index;

                // Export based on current tab
                switch (currentIndex) {
                  case 0: // Low Stock
                    lowStock.whenData((data) {
                      if (data.isEmpty) {
                        ToastUtils.showToast(
                            message: "No low stock items to export",
                            type: RequestState.error);
                      } else {
                        controller.exportNotificationsToExcel(
                            data, 'Low_Stock');
                      }
                    });
                    break;
                  case 1: // Expired Stock
                    expiredStock.whenData((data) {
                      if (data.isEmpty) {
                        ToastUtils.showToast(
                            message: "No expired items to export",
                            type: RequestState.error);
                      } else {
                        controller.exportNotificationsToExcel(
                            data, 'Expired_Stock');
                      }
                    });
                    break;
                  case 2: // Out of Stock
                    outOfStock.whenData((data) {
                      if (data.isEmpty) {
                        ToastUtils.showToast(
                            message: "No out of stock items to export",
                            type: RequestState.error);
                      } else {
                        controller.exportNotificationsToExcel(
                            data, 'Out_Of_Stock');
                      }
                    });
                    break;
                  case 3: // Pending Receipts
                    futurePendingReceipts.whenData((data) {
                      if (data.isEmpty) {
                        ToastUtils.showToast(
                            message: "No pending receipts to export",
                            type: RequestState.error);
                      } else {
                        controller.exportNotificationsToExcel(
                            data, 'Pending_Receipts');
                      }
                    });
                    break;
                }
              },
            ),

            kGap10,
          ],
        ),
        body: Column(children: [
          SizedBox(
            height: 60,
            child: TabBar(
              controller: _tabController,
              padding: const EdgeInsets.all(5),
              labelPadding: EdgeInsets.zero,
              labelColor: context.primaryColor,
              tabs: [
                Tab(
                  icon: lowStock.when(
                    data: (data) => Badge.count(
                      largeSize: 6,
                      count: data.length,
                      child: DefaultTextView(
                        text: S.of(context).lowStock,
                      ),
                    ),
                    loading: () => kEmptyWidget, // Show 0 while loading
                    error: (error, stack) =>
                        kEmptyWidget, // Show 0 if there's an error
                  ),
                ),
                Tab(
                  icon: expiredStock.when(
                    data: (data) => Badge.count(
                      largeSize: 6,
                      count: data.length,
                      child: DefaultTextView(
                        text: S.of(context).expiryDate,
                      ),
                    ),
                    loading: () => kEmptyWidget, // Show 0 while loading
                    error: (error, stack) =>
                        kEmptyWidget, // Show 0 if there's an error
                  ),
                ),
                Tab(
                  icon: outOfStock.when(
                    data: (data) => Badge.count(
                      largeSize: 6,
                      count: data.length,
                      child: DefaultTextView(
                        text: S.of(context).outOfStock,
                      ),
                    ),
                    loading: () => kEmptyWidget, // Show 0 while loading
                    error: (error, stack) =>
                        kEmptyWidget, // Show 0 if there's an error
                  ),
                ),
                Tab(
                  icon: futurePendingReceipts.when(
                    data: (data) => Badge.count(
                      largeSize: 6,
                      count: data.length,
                      child: DefaultTextView(
                        text:
                            "${S.of(context).pending} ${S.of(context).receipts}",
                      ),
                    ),
                    loading: () => kEmptyWidget, // Show 0 while loading
                    error: (error, stack) =>
                        kEmptyWidget, // Show 0 if there's an error
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                LowStockTab(),
                ExpiredStockTab(),
                ZeroStockTab(),
                PendingReceiptsTab()
              ],
            ),
          ),
        ]).baseContainer(context.cardColor));
  }
}
