import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/cupertino.dart';

class SupplierTableHeader extends StatelessWidget {
  const SupplierTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: DefaultTextView(
                fontWeight: FontWeight.bold,
                text: S.of(context).name.capitalizeFirstLetter())),
        Expanded(
            child: DefaultTextView(
                fontWeight: FontWeight.bold,
                text: S.of(context).phone.capitalizeFirstLetter())),
        Expanded(
            flex: 2,
            child: DefaultTextView(
                fontWeight: FontWeight.bold,
                text: S.of(context).contactDetails.capitalizeFirstLetter())),
        Expanded(
            child: DefaultTextView(
                fontWeight: FontWeight.bold,
                text: S.of(context).supplierAddress.capitalizeFirstLetter())),
        Expanded(
            flex: 2,
            child: DefaultTextView(
                fontWeight: FontWeight.bold,
                text:
                    '${S.of(context).edit.capitalizeFirstLetter()} / ${S.of(context).delete.capitalizeFirstLetter()}')),
      ],
    );
  }
}
