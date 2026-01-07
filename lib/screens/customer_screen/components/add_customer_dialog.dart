import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddCustomerDialog extends ConsumerWidget {
  AddCustomerDialog({this.isInCustomerScreen, super.key});
  final bool? isInCustomerScreen;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final nametextController = TextEditingController();
  final phoneNumbertextController = TextEditingController();
  final addresstextController = TextEditingController();
  final discountTextController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var customerController = ref.watch(customerControllerProvider);
    return AlertDialog(
      title: Center(child: Text(S.of(context).addCustomer)),
      content: SizedBox(
        width: 300,
        height: 330,
        child: Form(
          key: _formkey,
          child: ListView(
            children: [
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
                hinttext: S.of(context).customerName,
              ),
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
                hinttext: S.of(context).address,
              ),
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
                hinttext: S.of(context).phone,
              ),
              AppTextFormField(
                showText: true,
                format: numberDigitFormatter,
                controller: discountTextController,
                inputtype: TextInputType.phone,
                border: const UnderlineInputBorder(),
                hinttext: S.of(context).discount,
              ),
            ],
          ),
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
        customerController.addCustomerRequestState == RequestState.loading
            ? const SizedBox(
                width: 60,
                child: CoreCircularIndicator(coloredLogo: true),
              )
            : TextButton(
                onPressed: () async {
                  addCustomer(context, ref);
                },
                child: Text(S.of(context).add),
              ),
      ],
    );
  }

  void addCustomer(BuildContext context, WidgetRef ref) {
    if (_formkey.currentState!.validate()) {
      CustomerModel customerModel = CustomerModel(
        name: nametextController.text.trim(),
        address: addresstextController.text.trim(),
        phoneNumber: phoneNumbertextController.text.trim(),
        discount: int.tryParse(discountTextController.text) ?? 0,
      );

      ref
          .read(customerControllerProvider)
          .addCustomer(
            customerModel,
            context,
            isInCustomerScreen: isInCustomerScreen,
          );
    }
  }
}
