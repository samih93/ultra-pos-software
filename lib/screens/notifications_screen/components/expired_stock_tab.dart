import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/notifications_screen/components/expiry_date_selection_dialog.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpiredStockTab extends ConsumerWidget {
  const ExpiredStockTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureExpiredStock =
        ref.read(mainControllerProvider).isWorkWithIngredients
        ? ref.watch(futureRestaurantExpiredStockProvider)
        : ref.watch(futureMarketExpiredStockProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const DefaultTextView(
                text:
                    "Select the number of months to view products that will expire before this period:",
              ),
              kGap10,
              ElevatedButtonWidget(
                icon: Icons.calendar_month,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ExpiryDateSelectionDialog(),
                  );
                },
                text: "${ref.watch(nbOfMonthsProvider)} month(s)",
              ),
            ],
          ),
        ),
        kGap10,
        Expanded(
          child: futureExpiredStock.when(
            // While loading data
            loading: () => const Center(child: DefaultProgressIndicator()),

            // If data is loaded successfully
            data: (notifications) {
              // If no notifications, display a friendly message
              if (notifications.isEmpty) {
                return Center(
                  child: Text(
                    'No products are currently expired or nearing expiration within the next ${ref.watch(nbOfMonthsProvider)} months.',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              // Display a list of notifications
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: ListTile(
                              subtitle: DefaultTextView(
                                text:
                                    notification.subTitle ??
                                    'No additional information.',
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              title: DefaultTextView(
                                text: notification.title,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },

            // If an error occurs
            error: (error, stackTrace) => ErrorSection(
              retry: () {
                ref.refresh(futureMarketExpiredStockProvider);
              },
              title: error.toString(),
            ),
          ),
        ),
      ],
    );
  }
}
