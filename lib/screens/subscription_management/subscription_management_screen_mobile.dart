import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/subscription_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/subscription_model.dart';
import 'package:desktoppossystem/repositories/subscription/subscription_repository.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/subscription_management/components/subscription_card_mobile.dart';
import 'package:desktoppossystem/screens/subscription_management/components/subscription_summary_cards_mobile.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button_new.dart';
import 'package:desktoppossystem/shared/default%20components/debounced_text_form.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/reusable_confirm_dialog.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionManagementScreenMobile extends ConsumerWidget {
  const SubscriptionManagementScreenMobile({super.key});

  SubscriptionStatus? _getStatusFromIndex(int index) {
    switch (index) {
      case 0:
        return null; // All
      case 1:
        return SubscriptionStatus.active;
      case 2:
        return SubscriptionStatus.overdue; // Overdue (handled separately)

      case 3:
        return SubscriptionStatus.canceled;
      default:
        return null;
    }
  }

  int _getSelectedIndex(SubscriptionStatus? status, bool showOverdueOnly) {
    if (showOverdueOnly) return 2;
    if (status == null) return 0; // All
    switch (status) {
      case SubscriptionStatus.active:
        return 1;

      case SubscriptionStatus.overdue:
        return 2;

      case SubscriptionStatus.canceled:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionManagementProvider);
    final notifier = ref.read(subscriptionManagementProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          // Summary Cards - horizontal scrollable for mobile
          SubscriptionSummaryCardsMobile(stats: state.stats),

          kGap10,

          // Search Bar
          Padding(
            padding: kPaddH15,
            child: DebouncedTextFormField(
              prefixIcon: const Icon(Icons.search),
              onDebouncedChange: (query) {
                notifier.searchSubscriptions(query);
              },
              hinttext: "Search subscriptions...",
              initialValue: state.searchQuery,
            ),
          ),

          kGap10,

          Padding(
            padding: kPaddH15,
            child: CustomToggleButtonNew(
              height: 40,
              labels: [
                S.of(context).allSubscriptions,
                S.of(context).activeSubscriptions,
                S.of(context).overdueSubscriptions,
                S.of(context).cancelledSubscriptions,
              ],
              selectedIndex: _getSelectedIndex(
                state.selectedStatus,
                state.showOverdueOnly,
              ),
              onPressed: (index) {
                if (index == 2) {
                  // Overdue filter
                  notifier.filterOverdue();
                } else {
                  final status = _getStatusFromIndex(index);
                  notifier.filterByStatus(status);
                }
              },
            ),
          ),

          kGap10,

          // Subscriptions List
          Expanded(
            child: state.isLoading
                ? const Center(child: CoreCircularIndicator())
                : state.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        kGap15,
                        ElevatedButton(
                          onPressed: () {
                            notifier.refreshSubscriptions();
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : state.filteredSubscriptions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        kGap15,
                        Text(
                          S.of(context).noSubscriptions,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => notifier.refreshSubscriptions(),
                    child: ScrollConfiguration(
                      behavior: MyCustomScrollBehavior(),
                      child: ListView.separated(
                        padding: kPadd10,
                        itemCount: state.filteredSubscriptions.length,
                        separatorBuilder: (context, index) => kGap10,
                        itemBuilder: (context, index) {
                          final subscription =
                              state.filteredSubscriptions[index];
                          return SubscriptionCardMobile(
                            subscription: subscription,
                            onMakePayment: subscription.isOverdue
                                ? () {
                                    _showPaymentDialog(
                                      context,
                                      ref,
                                      subscription,
                                    );
                                  }
                                : null,
                            onEditPaymentDate: subscription.isActive
                                ? () {
                                    _showChangePaymentDateDialog(
                                      context,
                                      ref,
                                      subscription,
                                    );
                                  }
                                : null,
                            onEditMonthlyAmount: subscription.isActive
                                ? () {
                                    _showEditMonthlyAmountDialog(
                                      context,
                                      ref,
                                      subscription,
                                    );
                                  }
                                : null,
                            onResumeSubscription:
                                subscription.status ==
                                    SubscriptionStatus.canceled
                                ? () {
                                    _showResumeSubscriptionDialog(
                                      context,
                                      ref,
                                      subscription,
                                    );
                                  }
                                : null,
                            onCancelSubscription: subscription.isActive
                                ? () {
                                    _showCancelSubscriptionDialog(
                                      context,
                                      ref,
                                      subscription,
                                    );
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ).baseContainer(context.cardColor),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? Pallete.blueColor;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.transparent,
      selectedColor: chipColor.withValues(alpha: 0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : Colors.grey,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  // Show payment dialog
  void _showPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionModel subscription,
  ) {
    DateTime selectedPaymentDate = DateTime.parse(
      subscription.nextPaymentDate,
    ).add(const Duration(days: 30));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return Consumer(
            builder: (context, ref, child) {
              final subscriptionController = ref.watch(
                subscriptionControllerProvider,
              );
              final currentUser = ref.read(currentUserProvider);

              return ReusableConfirmDialog(
                title: S.of(context).makePayment,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextView(
                      text:
                          '${S.of(context).customerInfo}: ${subscription.customerName}',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    kGap10,

                    // Clickable next payment date
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedPaymentDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedPaymentDate = picked;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: DefaultTextView(
                              text:
                                  'Next Payment will be on: ${selectedPaymentDate.toString().split(' ').first}',
                              fontSize: 14,
                            ),
                          ),
                          kGap5,
                          const Icon(
                            Icons.edit,
                            size: 16,
                            color: Pallete.blueColor,
                          ),
                        ],
                      ),
                    ),

                    // Show months overdue if applicable
                    if (subscription.isOverdue) ...[
                      kGap5,
                      DefaultTextView(
                        text: subscription.overdueDisplayText,
                        fontSize: 14,
                        color: Pallete.redColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ],

                    kGap15,

                    // Total amount display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Pallete.greenColor.withValues(alpha: 0.1),
                        borderRadius: kRadius8,
                        border: Border.all(color: Pallete.greenColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DefaultTextView(
                            text: '${S.of(context).amount}:',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          DefaultTextView(
                            text: subscription.monthlyAmount.toStringAsFixed(2),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Pallete.greenColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                confirmText: S.of(context).pay,
                cancelText: S.of(context).cancel,
                gradientAcceptColor: mygreenLinearGradient(),
                isLoading: subscriptionController.isLoading,
                barrierDismissible: false,
                onConfirm: () async {
                  if (currentUser == null || currentUser.id == null) {
                    context.pop();
                    return;
                  }

                  // Pay single month with selected payment date
                  await ref
                      .read(subscriptionControllerProvider.notifier)
                      .processSubscriptionPayment(
                        customerId: subscription.customerId,
                        subscriptionId: subscription.id!,
                        amount: subscription.monthlyAmount,
                        userId: currentUser.id!,
                        paymentDate: selectedPaymentDate.toString(),
                        dollarRate: ref.read(saleControllerProvider).dolarRate,
                      );
                },
                onCancel: () {
                  context.pop();
                },
              );
            },
          );
        },
      ),
    );
  }

  // Show dialog to change next payment date
  void _showChangePaymentDateDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionModel subscription,
  ) {
    DateTime selectedDate = DateTime.parse(subscription.nextPaymentDate);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return ReusableConfirmDialog(
            title: S.of(context).changeNextPaymentDate,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextView(
                  text:
                      '${S.of(context).customerInfo}: ${subscription.customerName}',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                kGap15,
                DefaultTextView(
                  text:
                      '${S.of(context).currentDate}: ${subscription.nextPaymentDate.split(' ').first}',
                  fontSize: 14,
                ),
                kGap15,
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Pallete.blueColor.withValues(alpha: 0.1),
                      borderRadius: kRadius8,
                      border: Border.all(color: Pallete.blueColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DefaultTextView(
                          text: S.of(context).selectDate,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        Row(
                          children: [
                            DefaultTextView(
                              text: selectedDate.toString().split(' ').first,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Pallete.blueColor,
                            ),
                            kGap5,
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Pallete.blueColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isLoading: isLoading,
            onConfirm: () async {
              setState(() {
                isLoading = true;
              });

              final result = await ref
                  .read(subscriptionRepositoryProvider)
                  .updateNextPaymentDate(
                    subscriptionId: subscription.id!,
                    newNextPaymentDate: selectedDate.toString().substring(
                      0,
                      10,
                    ),
                  );

              if (dialogContext.mounted) {
                setState(() {
                  isLoading = false;
                });

                result.fold(
                  (failure) {
                    ToastUtils.showToast(
                      message: failure.message,
                      type: RequestState.error,
                    );
                  },
                  (_) {
                    ToastUtils.showToast(
                      message: S.of(context).nextPaymentDateUpdatedSuccessfully,
                      type: RequestState.success,
                    );
                    ref
                        .read(subscriptionManagementProvider.notifier)
                        .refreshSubscriptions();
                    context.pop();
                  },
                );
              }
            },
            onCancel: () {
              if (!isLoading) {
                context.pop();
              }
            },
          );
        },
      ),
    );
  }

  // Show dialog to edit monthly amount
  void _showEditMonthlyAmountDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionModel subscription,
  ) {
    final TextEditingController amountController = TextEditingController(
      text: subscription.monthlyAmount.toString(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return ReusableConfirmDialog(
            title: S.of(context).editMonthlyAmount,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextView(
                  text:
                      '${S.of(context).customerInfo}: ${subscription.customerName}',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                kGap15,
                DefaultTextView(
                  text:
                      '${S.of(context).currentAmount}: ${subscription.monthlyAmount.formatDouble()}',
                  fontSize: 14,
                ),
                kGap15,
                AppTextFormField(
                  controller: amountController,
                  format: numberDigitFormatter,
                ),
              ],
            ),
            isLoading: isLoading,
            onConfirm: () async {
              final newAmount = double.tryParse(amountController.text);

              if (newAmount == null || newAmount <= 0) {
                ToastUtils.showToast(
                  message: S.of(context).pleaseEnterValidAmount,
                  type: RequestState.error,
                );
                return;
              }

              setState(() {
                isLoading = true;
              });

              final result = await ref
                  .read(subscriptionRepositoryProvider)
                  .updateMonthlyAmount(
                    subscriptionId: subscription.id!,
                    newMonthlyAmount: newAmount,
                  );

              if (dialogContext.mounted) {
                setState(() {
                  isLoading = false;
                });

                result.fold(
                  (failure) {
                    ToastUtils.showToast(
                      message: failure.message,
                      type: RequestState.error,
                    );
                  },
                  (_) {
                    ToastUtils.showToast(
                      message: S.of(context).monthlyAmountUpdatedSuccessfully,
                      type: RequestState.success,
                    );
                    ref
                        .read(subscriptionManagementProvider.notifier)
                        .refreshSubscriptions();
                    context.pop();
                  },
                );
              }
            },
            onCancel: () {
              if (!isLoading) {
                context.pop();
              }
            },
          );
        },
      ),
    );
  }

  // Show dialog to cancel subscription
  void _showCancelSubscriptionDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionModel subscription,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return ReusableConfirmDialog(
            title: S.of(context).cancelSubscription,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextView(
                  text:
                      '${S.of(context).customerInfo}: ${subscription.customerName}',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                kGap15,
                DefaultTextView(
                  text: S.of(context).cancelSubscriptionConfirmation,
                  fontSize: 14,
                ),
              ],
            ),
            confirmText: S.of(context).confirm,
            cancelText: S.of(context).cancel,
            isDestructive: true,
            isLoading: isLoading,
            barrierDismissible: false,
            onConfirm: () async {
              setState(() {
                isLoading = true;
              });

              final result = await ref
                  .read(subscriptionRepositoryProvider)
                  .cancelSubscription(subscription.id!);

              if (dialogContext.mounted) {
                setState(() {
                  isLoading = false;
                });

                result.fold(
                  (failure) {
                    ToastUtils.showToast(
                      message: failure.message,
                      type: RequestState.error,
                    );
                  },
                  (_) {
                    ToastUtils.showToast(
                      message: S.of(context).subscriptionCancelledSuccessfully,
                      type: RequestState.success,
                    );
                    ref
                        .read(subscriptionManagementProvider.notifier)
                        .refreshSubscriptions();
                    context.pop();
                  },
                );
              }
            },
            onCancel: () {
              if (!isLoading) {
                context.pop();
              }
            },
          );
        },
      ),
    );
  }

  // Show dialog to resume subscription
  void _showResumeSubscriptionDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionModel subscription,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return ReusableConfirmDialog(
            title: S.of(context).resumeSubscription,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextView(
                  text:
                      '${S.of(context).customerInfo}: ${subscription.customerName}',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                kGap15,
                DefaultTextView(
                  text: S.of(context).resumeSubscriptionConfirmation,
                  fontSize: 14,
                ),
              ],
            ),
            confirmText: S.of(context).confirm,
            cancelText: S.of(context).cancel,
            gradientAcceptColor: mygreenLinearGradient(),
            isLoading: isLoading,
            barrierDismissible: false,
            onConfirm: () async {
              setState(() {
                isLoading = true;
              });

              final result = await ref
                  .read(subscriptionRepositoryProvider)
                  .resumeSubscription(subscription.id!);

              if (dialogContext.mounted) {
                setState(() {
                  isLoading = false;
                });

                result.fold(
                  (failure) {
                    ToastUtils.showToast(
                      message: failure.message,
                      type: RequestState.error,
                    );
                  },
                  (_) {
                    ToastUtils.showToast(
                      message: S.of(context).subscriptionResumedSuccessfully,
                      type: RequestState.success,
                    );
                    ref
                        .read(subscriptionManagementProvider.notifier)
                        .refreshSubscriptions();
                    context.pop();
                  },
                );
              }
            },
            onCancel: () {
              if (!isLoading) {
                context.pop();
              }
            },
          );
        },
      ),
    );
  }
}
