// ignore_for_file: public_member_api_docs, sort_constructors_first
class ShiftModel {
  int? id = 1;
  String? startShiftDate;
  String? endShiftDate;
  ShiftModel({this.id, required this.startShiftDate, this.endShiftDate});

  ShiftModel.second();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'startShiftDate': startShiftDate,
      'endShiftDate': endShiftDate,
    };
  }

  factory ShiftModel.fromJson(Map<String, dynamic> map) {
    return ShiftModel(
        id: map['id'] as int,
        startShiftDate: map['startShiftDate'],
        endShiftDate: map['endShiftDate']);
  }
  Map<String, dynamic> toJsonForInsert() {
    return <String, dynamic>{
      'startShiftDate': startShiftDate,
      'endShiftDate': endShiftDate,
    };
  }

  @override
  bool operator ==(covariant ShiftModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.startShiftDate == startShiftDate;
  }

  @override
  int get hashCode => id.hashCode ^ startShiftDate.hashCode;
}
