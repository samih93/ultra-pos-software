import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditCustomerDialog extends ConsumerWidget {
  EditCustomerDialog(this.customerModel, {this.isInCustomerScreen, super.key});
  final CustomerModel customerModel;
  final bool? isInCustomerScreen;
  final GlobalKey<FormState> _editformkey = GlobalKey<FormState>();
  final nametextController = TextEditingController();
  final phoneNumbertextController = TextEditingController();
  final addresstextController = TextEditingController();
  final discountTextController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    nametextController.text = customerModel.name.toString();
    phoneNumbertextController.text = customerModel.phoneNumber.toString();
    addresstextController.text = customerModel.address.toString();
    discountTextController.text = customerModel.discount.toString();
    var customerController = ref.watch(customerControllerProvider);
    return AlertDialog(
      title: Center(child: Text(S.of(context).updateCustomer)),
      content: SizedBox(
        width: 300,
        height: 290,
        child: Form(
          key: _editformkey,
          child: ListView(children: [
            AppTextFormField(
                showText: true,
                format: [EnglishOnlyTextInputFormatter()],
                onvalidate: (value) {
                  if (value!.isEmpty) {
                    return S.of(context).nameMustBeNotEmpty;
                  }
                  return null;
                },
                controller: nametextController,
                inputtype: TextInputType.name,
                border: const UnderlineInputBorder(),
                hinttext: S.of(context).customerName),
            AppTextFormField(
                showText: true,
                format: [EnglishOnlyTextInputFormatter()],
                onvalidate: (value) {
                  if (value!.isEmpty) {
                    return S.of(context).addressMustNotBeEmpty;
                  }
                  return null;
                },
                controller: addresstextController,
                inputtype: TextInputType.name,
                border: const UnderlineInputBorder(),
                hinttext: S.of(context).address),
            AppTextFormField(
                showText: true,
                format: [EnglishOnlyTextInputFormatter()],
                onvalidate: (value) {
                  if (value!.isEmpty) {
                    return S.of(context).phoneMustNotBeEmpty;
                  }
                  return null;
                },
                controller: phoneNumbertextController,
                inputtype: TextInputType.name,
                border: const UnderlineInputBorder(),
                hinttext: S.of(context).phone),
            AppTextFormField(
                showText: true,
                format: numberDigitFormatter,
                controller: discountTextController,
                inputtype: TextInputType.phone,
                border: const UnderlineInputBorder(),
                hinttext: S.of(context).discount),
          ]),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            nametextController.clear();
            addresstextController.clear();
            phoneNumbertextController.clear();
            discountTextController.clear();
            context.pop();
          },
          child: Text(S.of(context).cancel),
        ),
        customerController.updateCustomerRequestState == RequestState.loading
            ? const SizedBox(width: 60, child: DefaultProgressIndicator())
            : TextButton(
                onPressed: () async {
                  updateCustomer(context, ref);
                },
                child: Text(S.of(context).update),
              ),
      ],
    );
  }

  void updateCustomer(BuildContext context, WidgetRef ref) {
    if (_editformkey.currentState!.validate()) {
      CustomerModel updatedCustomer = CustomerModel(
          id: customerModel.id,
          name: nametextController.text.trim(),
          address: addresstextController.text.trim(),
          phoneNumber: phoneNumbertextController.text.trim(),
          discount: int.tryParse(discountTextController.text) ?? 0);

      ref.read(customerControllerProvider).updateCustomer(
          updatedCustomer, context,
          isInCustomerScreen: isInCustomerScreen);
    }
  }
}
