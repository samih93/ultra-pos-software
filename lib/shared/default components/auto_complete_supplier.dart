import 'package:desktoppossystem/controller/supplier_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/supplier_model.dart';
import 'package:desktoppossystem/screens/purchases_screen/components/add_edit_supplier_dialog.dart';
import 'package:desktoppossystem/screens/suppliers_screen/suppliers_screen.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AutoCompleteSupplier extends ConsumerWidget {
  AutoCompleteSupplier({required this.onSelectSupplier, super.key});
  final Function(SupplierModel) onSelectSupplier;
  var textSearchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var supplierController = ref.read(supplierControllerProvider);
    return Container(
      width: context.width * 0.27,
      color: Pallete.whiteColor,
      child: Row(
        children: [
          Expanded(
            child: TypeAheadField<SupplierModel>(
              hideOnError: true,
              hideOnEmpty: true,
              builder: (context, controller, focusNode) {
                textSearchController = controller;

                return AppTextFormField(
                  inputtype: TextInputType.text,
                  controller: textSearchController,
                  focusNode: focusNode,
                  hinttext: " ${S.of(context).supplier}",
                );
              },
              itemBuilder: (context, SupplierModel? suggestion) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      tileColor: Colors.white,
                      subtitle: DefaultTextView(
                        color: Colors.black,
                        text: "${suggestion?.phoneNumber}",
                      ),
                      title: DefaultTextView(
                        maxlines: 2,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        text: "${suggestion?.name}",
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 1,
                    )
                  ],
                );
              },
              suggestionsCallback: (String query) async {
                if (query.trim() == "") return [];
                var suppliers = await ref
                    .read(supplierControllerProvider)
                    .autoCompleteSupplierByName(query);
                return suppliers.toList();
              },
              onSelected: (SupplierModel value) {
                onSelectSupplier(value);
                textSearchController.clear();
                ref.invalidate(supplierControllerProvider);
              },
            ),
          ),
          kGap5,
          ElevatedButtonWidget(
            height: 45,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const AddEditSupplierDialog();
                },
              );
            },
            text: S.of(context).add,
            icon: Icons.add,
          ),
          kGap5,
          ElevatedButtonWidget(
            height: 45,
            onPressed: () {
              ref
                  .read(supplierControllerProvider)
                  .fetchSuppliersByBatch(batch: 20, offset: 0);
              context.to(const SuppliersScreen());
            },
            text: "${S.of(context).show} ${S.of(context).all}",
            icon: Icons.list_rounded,
          ),
        ],
      ),
    );
  }
}
