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
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../main_screen.dart/main_controller.dart';

class CustomerHedear extends ConsumerWidget {
  const CustomerHedear({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var customerController = ref.watch(customerControllerProvider);
    var userModel = ref.read(currentUserProvider);
    var futureCustomersCount = ref.watch(customerCountsProvider);

    return Row(
      children: [
        Row(
          children: [
            DefaultTextView(
              text: S.of(context).numberOfCustomers,
              fontSize: 18,
            ),
            kGap10,
            futureCustomersCount.when(
              data: (data) => DefaultTextView(
                text: "($data)",
                color: context.primaryColor,
                fontSize: 18,
              ),
              error: (error, stackTrace) => kEmptyWidget,
              loading: () =>
                  const SizedBox(width: 30, child: CoreCircularIndicator()),
            ),
          ],
        ),
        Expanded(
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 250,
                child: AppTextFormField(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Pallete.greyColor,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: context.primaryColor),
                  ),
                  onchange: (value) {
                    ref
                        .read(customerControllerProvider)
                        .searchByPhoneOrName(value.toString());
                  },
                  inputtype: TextInputType.name,
                  hinttext: S.of(context).search,
                ),
              ),
              if (ref.watch(mainControllerProvider).isAdmin) ...[
                AppSquaredOutlinedButton(
                  states: [customerController.getDownloadCustomersRequestState],
                  onPressed: () async {
                    await downloadCustomers(context, ref);
                  },
                  child: const Icon(
                    FontAwesomeIcons.fileExcel,
                    color: Pallete.greenColor,
                  ),
                ),
                AppSquaredOutlinedButton(
                  size: const Size(90, 38),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(FontAwesomeIcons.fileImport, size: 20),
                      DefaultTextView(
                        text: S.of(context).import,
                        color: Pallete.blackColor,
                      ),
                    ],
                  ),
                  onPressed: () {
                    context.to(const ImportCustomersScreen());
                  },
                ),
              ],
              AppSquaredOutlinedButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AddCustomerDialog(isInCustomerScreen: true),
                  );
                },
              ),
            ],
          ),
        ),
      ],
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
