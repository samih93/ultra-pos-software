import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LowStockTab extends ConsumerWidget {
  const LowStockTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockAsyncValue =
        ref.read(mainControllerProvider).isWorkWithIngredients
        ? ref.watch(futureRestaurantLowStockProvider)
        : ref.watch(futureMarketLowStockProvider);

    final isAdmin = ref.read(mainControllerProvider).isAdmin;
    return lowStockAsyncValue.when(
      // While loading data
      loading: () => const Center(child: DefaultProgressIndicator()),

      // If data is loaded successfully
      data: (notifications) {
        // If no notifications, display a friendly message
        if (notifications.isEmpty) {
          return const Center(
            child: Text(
              'No products are currently low on stock.',
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
                  onTap: isAdmin
                      ? () async {
                          final product = await ref
                              .read(productControllerProvider)
                              .fetchProductById(notification.id);
                          context.to(
                            AddEditProductScreen(
                              product,
                              null,
                              fromNotifications: true,
                            ),
                          );
                        }
                      : null,
                  subtitle: DefaultTextView(
                    text: notification.subTitle ?? 'No additional information.',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  trailing: DefaultTextView(
                    text: 'Qty: ${notification.qty}',
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
      error: (error, stackTrace) => Center(
        child: Text(
          'An error occurred: $error',
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }
}
