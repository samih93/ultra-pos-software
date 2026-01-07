import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/controller/supplier_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/purchases_screen/components/add_edit_supplier_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupplierHedear extends ConsumerWidget {
  const SupplierHedear({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var supplierController = ref.watch(supplierControllerProvider);
    var futureCustomersCount = ref.watch(customerCountsProvider);

    return Row(
      spacing: 5,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 250,
          child: AppTextFormField(
            prefixIcon: const Icon(Icons.search, color: Pallete.greyColor),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: context.primaryColor),
            ),
            onchange: (value) {
              ref
                  .read(supplierControllerProvider)
                  .searchByNameOrPhone(value.toString());
            },
            inputtype: TextInputType.name,
            hinttext: S.of(context).search,
          ),
        ),
        AppSquaredOutlinedButton(
          size: const Size(42, 42),
          child: const Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddEditSupplierDialog(),
            );
          },
        ),
      ],
    );
  }
}
