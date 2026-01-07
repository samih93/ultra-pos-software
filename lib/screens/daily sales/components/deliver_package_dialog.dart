import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:desktoppossystem/models/receipt_model.dart'; // Import your model

class DeliverPackageDialog extends ConsumerStatefulWidget {
  final ReceiptModel receiptModel;

  const DeliverPackageDialog({
    super.key,
    required this.receiptModel,
  });

  @override
  ConsumerState<DeliverPackageDialog> createState() =>
      _DeliverPackageDialogState();
}

class _DeliverPackageDialogState extends ConsumerState<DeliverPackageDialog> {
  RequestState deliverRequest = RequestState.success;
  final textNoteController = TextEditingController();

  @override
  void dispose() {
    textNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.receiptModel.customerModel;
    return AreYouSureDialog(
      textColor: Pallete.greenColor,
      agreeText: S.of(context).deliverPackage,
      onCancel: () => context.pop(),
      agreeState: deliverRequest,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTextView(text: "Name : ${customer?.name ?? '-'}"),
          kGap5,
          DefaultTextView(
              text: "phone Number : ${customer?.phoneNumber ?? '-'}"),
          kGap5,
          DefaultTextView(text: "Address : ${customer?.address ?? '-'}"),
          kGap10,
          AppTextFormField(
            minline: 2,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            controller: textNoteController,
            hinttext: S.of(context).note.capitalizeFirstLetter(),
            maxligne: 2,
          ),
        ],
      ),
      onAgree: () async {
        if (!mounted) return;
        setState(() {
          deliverRequest = RequestState.loading;
        });
        await ref.read(receiptControllerProvider).deliverInvoice(
              receiptModel: widget.receiptModel,
              note: textNoteController.text.trim(),
            );
        if (!mounted) return;
        setState(() {
          deliverRequest = RequestState.success;
        });
        context.pop();
        context.pop();
      },
      "Are you sure you want to deliver package ?",
    );
  }
}
