import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Container invoiceItem(BuildContext context, WidgetRef ref, int e, String note) {
  return Container(
    margin: const EdgeInsets.only(bottom: 5),
    decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.6),
        borderRadius: kRadius5),
    child: ListTile(
      onTap: () {
        ref.read(saleControllerProvider).onOpenHoldInvoice(e);
        context.pop();
      },
      title: DefaultTextView(
          color: Colors.white,
          textAlign: TextAlign.center,
          text: note.isNotEmpty ? note : "${S.of(context).invoice} $e"),
    ),
  );
}
