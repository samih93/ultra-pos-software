import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';

customerRowItem(CustomerModel customerModel, int index) => Row(
      children: [
        Expanded(
          child: DefaultTextView(
            text: "${index + 1}-  ${customerModel.name.toString()}",
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: DefaultTextView(
            text: customerModel.address.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: DefaultTextView(
            text: customerModel.phoneNumber.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
