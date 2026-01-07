// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:desktoppossystem/models/customers_model.dart';

class NotificationModel {
  int id;
  String title;
  String? subTitle;
  double qty;
  CustomerModel? customerModel;

  NotificationModel(
      {required this.id,
      required this.title,
      this.subTitle,
      required this.qty,
      this.customerModel});

  NotificationModel copyWith({
    String? title,
    String? subTitle,
    double? qty,
    CustomerModel? customerModel,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      qty: qty ?? this.qty,
      customerModel: customerModel ?? this.customerModel,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'subTitle': subTitle,
      'qty': qty,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int,
      title: map['title'] as String,
      subTitle: map['subTitle'] != null ? map['subTitle'] as String : null,
      qty: double.tryParse(map['qty'].toString()) ?? 0,
    );
  }

  @override
  String toString() =>
      'NotificationModel(title: $title, subTitle: $subTitle, qty: $qty)';

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.subTitle == subTitle &&
        other.qty == qty;
  }

  @override
  int get hashCode => title.hashCode ^ subTitle.hashCode ^ qty.hashCode;
}
