import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/customer_screen/components/add_customer_dialog.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/import%20customers/import_customers_screen.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../main_screen.dart/main_controller.dart';

class CustomerHeaderMobile extends ConsumerWidget {
  const CustomerHeaderMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var customerController = ref.watch(customerControllerProvider);
    var userModel = ref.read(currentUserProvider);
    var futureCustomersCount = ref.watch(customerCountsProvider);

    return Padding(
      padding: kPaddH15,
      child: Column(
        children: [
          // Title and Count
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    DefaultTextView(
                      text: S.of(context).numberOfCustomers,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    kGap10,
                    futureCustomersCount.when(
                      data: (data) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          borderRadius: kRadius8,

                          border: Border.all(color: context.primaryColor),
                        ),
                        child: DefaultTextView(
                          text: "$data",
                          color: context.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      error: (error, stackTrace) => kEmptyWidget,
                      loading: () => const SizedBox(
                        width: 30,
                        child: CoreCircularIndicator(),
                      ),
                    ),
                  ],
                ),
              ),
              // Add Customer Button
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AddCustomerDialog(isInCustomerScreen: true),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Pallete.greenColor.withValues(alpha: 0.1),
                    borderRadius: kRadius8,
                    border: Border.all(color: Pallete.greenColor),
                  ),
                  child: const Icon(Icons.add, color: Pallete.greenColor),
                ),
              ),
            ],
          ),

          // Search Bar
          AppTextFormField(
            prefixIcon: const Icon(Icons.search, color: Pallete.greyColor),

            onchange: (value) {
              ref
                  .read(customerControllerProvider)
                  .searchByPhoneOrName(value.toString());
            },
            inputtype: TextInputType.name,
            hinttext: S.of(context).search,
          ),

          // Action Buttons (Admin only)
          if (ref.watch(mainControllerProvider).isAdmin) ...[
            kGap10,
            Padding(
              padding: kPaddH15,
              child: Row(
                children: [
                  Expanded(
                    child: AppSquaredOutlinedButton(
                      states: [
                        customerController.getDownloadCustomersRequestState,
                      ],
                      onPressed: () async {
                        await downloadCustomers(context, ref);
                      },

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.fileExcel,
                            size: 16,
                            color: Pallete.greenColor,
                          ),
                          kGap5,
                          DefaultTextView(
                            text: S.of(context).download,
                            fontSize: 16,
                            color: Pallete.greenColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  kGap10,
                  Expanded(
                    child: AppSquaredOutlinedButton(
                      onPressed: () {
                        context.to(const ImportCustomersScreen());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FontAwesomeIcons.fileImport, size: 16),
                          kGap5,
                          DefaultTextView(
                            text: S.of(context).import,
                            fontSize: 16,
                            color: Pallete.blackColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          kGap15,
        ],
      ),
    );
  }

  Future<void> downloadCustomers(BuildContext context, WidgetRef ref) async {
    await ref.read(customerControllerProvider).getAllCustomers().then((
      customers,
    ) {
      ref.read(globalControllerProvider).openCustomersInExcel(customers);
    });
  }
}
