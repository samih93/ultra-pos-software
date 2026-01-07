import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/customer_screen/components/add_customer_dialog.dart';
import 'package:desktoppossystem/screens/customer_screen/components/edit_customer_dialog.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomerSection extends ConsumerWidget {
  const CustomerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);
    UserModel usermodel =
        ref.watch(currentUserProvider) ?? UserModel.fakeUser();
    bool isTableSelected = saleController.selectedTable != null;

    return usermodel.role?.name != AuthRole.waiterRole && !isTableSelected
        ? Builder(
            builder: (customerContext) => Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      SizedBox(
                        height: 45,
                        child: TypeAheadField<CustomerModel>(
                          animationDuration: const Duration(milliseconds: 50),
                          hideOnError: true,
                          hideOnEmpty: true,
                          itemBuilder: (context, CustomerModel? suggestion) {
                            return ListTile(
                              title: Text(
                                "${suggestion!.name} -  ${suggestion.address} - ${suggestion.phoneNumber}  ${suggestion.discount! > 0 ? ' - ${suggestion.discount} %' : ''}",
                              ),
                            );
                          },
                          builder: (context, controller, focusNode) {
                            controller.text =
                                saleController.customerTextController.text;
                            return AppTextFormField(
                              format: [EnglishOnlyTextInputFormatter()],
                              inputtype: TextInputType.text,
                              readonly: saleController.customerModel != null
                                  ? true
                                  : false,
                              controller: controller,
                              focusNode: focusNode,
                              hinttext: S.of(context).selectCustomer,
                            );
                          },
                          suggestionsCallback: (String pattern) async {
                            List<CustomerModel> customers = pattern.isNotEmpty
                                ? await ref
                                      .read(customerControllerProvider)
                                      .getCustomersByPhoneOrNumber(pattern)
                                : [];
                            return customers;
                          },
                          onSelected: (CustomerModel customerModel) {
                            saleController.onselectCustomer(customerModel);
                          },
                        ),
                      ),
                      saleController.customerModel != null
                          ? IconButton(
                              onPressed: () {
                                saleController.clearCustomer();
                              },
                              icon: const Icon(Icons.close, color: Colors.red),
                            )
                          : kEmptyWidget,
                    ],
                  ),
                ),
                kGap10,
                AppSquaredOutlinedButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddCustomerDialog(),
                    );
                  },
                ),
                kGap5,
                AppSquaredOutlinedButton(
                  isDisabled: saleController.customerModel == null,
                  onPressed: () {
                    if (saleController.customerModel != null) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            EditCustomerDialog(saleController.customerModel!),
                      );
                    }
                  },
                  child: const Icon(Icons.edit_note),
                ),
              ],
            ),
          )
        : kEmptyWidget;
  }
}
