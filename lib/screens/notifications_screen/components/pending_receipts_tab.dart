import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/invoices_by_customer_screen.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingReceiptsTab extends ConsumerWidget {
  const PendingReceiptsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var futurePendingReceipts = ref.watch(futurePendingReceiptsNotification);

    return futurePendingReceipts.when(
      // While loading data
      loading: () => const Center(child: CoreCircularIndicator()),

      // If data is loaded successfully
      data: (notifications) {
        // If no notifications, display a friendly message
        if (notifications.isEmpty) {
          return const Center(
            child: Text(
              'No Pending Receipts.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        // Display a list of notifications
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  onTap: () {
                    if (notification.customerModel != null) {
                      context.to(
                        InvoicesByCustomerScreen(
                          customer: notification.customerModel!,
                        ),
                      );
                    }
                  },
                  subtitle: DefaultTextView(
                    text: notification.subTitle ?? 'No additional information.',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  trailing: DefaultTextView(
                    text:
                        'Pending Amount: ${notification.qty.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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
        );
      },

      // If an error occurs
      error: (error, stackTrace) => ErrorSection(
        retry: () {
          ref.refresh(futurePendingReceiptsNotification);
        },
        title: error.toString(),
      ),
    );
  }
}
