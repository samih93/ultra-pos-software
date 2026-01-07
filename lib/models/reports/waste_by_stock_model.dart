// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:desktoppossystem/shared/utils/enum.dart';

class WasteByStockModel {
  String name;
  UnitType unitType;
  double totalQtyAsPortions;
  double totalQtyAsKg;
  double totalPrice;
  WasteByStockModel({
    required this.name,
    required this.unitType,
    required this.totalQtyAsPortions,
    required this.totalQtyAsKg,
    required this.totalPrice,
  });
}
