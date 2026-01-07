import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';

productRowItem(ProductModel productModel, int index) => Row(
      children: [
        Expanded(
          flex: 2,
          child: DefaultTextView(
            text: "${index + 1}-  ${productModel.name.toString()}",
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: DefaultTextView(
            text: productModel.barcode.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: DefaultTextView(
            text: productModel.costPrice.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: DefaultTextView(
            text: productModel.sellingPrice.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: DefaultTextView(
            text: productModel.qty.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: DefaultTextView(
            text: productModel.isTracked.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
