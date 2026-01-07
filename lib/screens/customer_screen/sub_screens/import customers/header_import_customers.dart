import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';

buildImportCustomerHeader(BuildContext context) => Row(
  children: [
    Expanded(
      child: DefaultTextView(
        text: S.of(context).customerName,
        textAlign: TextAlign.center,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    Expanded(
      child: DefaultTextView(
        text: S.of(context).address,
        textAlign: TextAlign.center,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    Expanded(
      child: DefaultTextView(
        text: S.of(context).phone,
        textAlign: TextAlign.center,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
);
