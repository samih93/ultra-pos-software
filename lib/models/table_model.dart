import 'package:desktoppossystem/models/product_model.dart';

class TableModel {
  int? id;
  String? tableName;
  bool isOpened;
  int? openedBy;
  List<ProductModel> products = [];
  TableModel({this.id, this.tableName, required this.isOpened, this.openedBy});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      'tableName': tableName,
      'isOpened': isOpened ? 1 : 0,
      'openedBy': openedBy,
    };
  }

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
        id: map['id'] != null ? map['id'] as int : null,
        tableName: map['tableName'] != null ? map['tableName'] as String : null,
        isOpened: map['isOpened'] != null
            ? map['isOpened'] == 0
                ? false
                : true
            : false,
        openedBy: map['openedBy']);
  }
}
