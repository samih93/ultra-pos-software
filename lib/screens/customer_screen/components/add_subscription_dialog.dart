import 'package:desktoppossystem/controller/subscription_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddSubscriptionDialog extends ConsumerStatefulWidget {
  const AddSubscriptionDialog({required this.customerModel, super.key});

  final CustomerModel customerModel;

  @override
  ConsumerState<AddSubscriptionDialog> createState() =>
      _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends ConsumerState<AddSubscriptionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final monthlyAmountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    monthlyAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionControllerProvider);

    return AlertDialog(
      title: const Center(
        child: DefaultTextView(
          text: 'Add Subscription',
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 350,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: .start,
            children: [
              // Customer Name Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        DefaultTextView(
                          text: 'Customer',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        DefaultTextView(
                          color: Pallete.blackColor,
                          text: widget.customerModel.name ?? 'Unknown',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Monthly Amount Field
              AppTextFormField(
                showText: true,
                format: numberDigitFormatter,
                onvalidate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Monthly amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                controller: monthlyAmountController,
                inputtype: TextInputType.number,
                hinttext: 'Monthly Amount',
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 20),

              // Start Date Picker
              Row(
                children: [
                  const DefaultTextView(text: 'Start Date :', fontSize: 14),
                  kGap20,
                  ElevatedButtonWidget(
                    icon: Icons.calendar_month_outlined,
                    text: DateFormat('yyyy-MM-dd').format(selectedDate),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Info Text
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Next payment will be due 30 days from start date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: subscriptionState.isLoading ? null : () => context.pop(),
          child: Text(S.of(context).cancel),
        ),
        AppSquaredOutlinedButton(
          size: const Size(80, 38),
          states: [
            subscriptionState.isLoading
                ? RequestState.loading
                : RequestState.success,
          ],
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(monthlyAmountController.text);
              // Format date as YYYY-MM-DD string
              final formattedDate = DateFormat(
                'yyyy-MM-dd',
              ).format(selectedDate);

              await ref
                  .read(subscriptionControllerProvider.notifier)
                  .createSubscription(
                    customer: widget.customerModel,
                    monthlyAmount: amount,
                    startDate: formattedDate,
                  );
            }
          },
          child: const DefaultTextView(text: 'Create'),
        ),
      ],
    );
  }
}
