import 'package:desktoppossystem/controller/supplier_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/supplier_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditSupplierDialog extends ConsumerStatefulWidget {
  final SupplierModel? supplier; // The optional parameter for editing

  const AddEditSupplierDialog({super.key, this.supplier});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddSupplierDialogState();
}

class _AddSupplierDialogState extends ConsumerState<AddEditSupplierDialog> {
  late TextEditingController nameTextController;
  late TextEditingController phoneTextController;
  late TextEditingController contactDetailsTextController;
  late TextEditingController supplierAddressTextController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    nameTextController = TextEditingController();
    phoneTextController = TextEditingController();
    contactDetailsTextController = TextEditingController();
    supplierAddressTextController = TextEditingController();

    // If a supplier is passed, populate the fields with its data
    if (widget.supplier != null) {
      nameTextController.text = widget.supplier!.name;
      phoneTextController.text = widget.supplier!.phoneNumber ?? '';
      contactDetailsTextController.text = widget.supplier!.contactDetails ?? '';
      supplierAddressTextController.text =
          widget.supplier!.supplierAddress ?? '';
    }
  }

  @override
  void dispose() {
    nameTextController.dispose();
    phoneTextController.dispose();
    contactDetailsTextController.dispose();
    supplierAddressTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: DefaultTextView(
            fontWeight: FontWeight.bold,
            text: widget.supplier == null
                ? "${S.of(context).add} ${S.of(context).supplier}"
                : "${S.of(context).edit} ${S.of(context).supplier}"),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextFormField(
            controller: nameTextController,
            hinttext: S.of(context).name,
          ),
          kGap5,
          AppTextFormField(
            controller: phoneTextController,
            hinttext: S.of(context).phone,
          ),
          kGap5,
          AppTextFormField(
            controller: contactDetailsTextController,
            hinttext: S.of(context).contactDetails,
          ),
          kGap5,
          AppTextFormField(
            controller: supplierAddressTextController,
            hinttext: S.of(context).supplierAddress,
          ),
          kGap15,
          Row(
            children: [
              Expanded(
                child: ElevatedButtonWidget(
                  text: widget.supplier == null
                      ? S.of(context).save
                      : S
                          .of(context)
                          .update, // Save or Update depending on context
                  icon: widget.supplier == null ? Icons.add : Icons.edit,
                  onPressed: () async {
                    String name = nameTextController.text.trim();
                    String phone = phoneTextController.text.trim();

                    if (name.isNotEmpty && phone.isNotEmpty) {
                      SupplierModel s = SupplierModel(
                        name: name,
                        phoneNumber: phone,
                        contactDetails:
                            contactDetailsTextController.text.trim(),
                        supplierAddress:
                            supplierAddressTextController.text.trim(),
                      );

                      if (widget.supplier == null) {
                        // If no supplier model, add a new one
                        await ref
                            .read(supplierControllerProvider)
                            .addSupplier(context, s);
                      } else {
                        s = s.copyWith(id: widget.supplier!.id!);
                        // If there's a supplier model, update the existing one
                        await ref
                            .read(supplierControllerProvider)
                            .updateSupplier(context, s);
                      }
                    } else {
                      ToastUtils.showToast(
                          message: "Please fill name and phone and try again",
                          type: RequestState.error);
                    }
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
