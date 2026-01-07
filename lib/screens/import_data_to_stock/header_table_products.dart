import 'package:flutter/material.dart';

import '../../shared/default components/default_text_view.dart';

buildHeader() => const Row(
  children: [
    Expanded(
      flex: 2,
      child: DefaultTextView(
        text: "product name",
        textAlign: TextAlign.center,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    Expanded(
      flex: 2,
      child: DefaultTextView(
        text: "barcode",
        textAlign: TextAlign.center,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    Expanded(
      child: DefaultTextView(
        text: "cost",
        textAlign: TextAlign.center,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    Expanded(
      child: DefaultTextView(
        text: "selling",
        textAlign: TextAlign.center,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    Expanded(
      child: DefaultTextView(
        text: "qty",
        textAlign: TextAlign.center,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    Expanded(
      child: DefaultTextView(
        text: "tracked",
        textAlign: TextAlign.center,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
);
