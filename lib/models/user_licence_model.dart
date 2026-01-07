// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserLicencesModel {
  String userId;
  String validDate;
  String createdAt;
  int activatedBy;
  UserLicencesModel(
      {required this.userId,
      required this.validDate,
      required this.createdAt,
      required this.activatedBy});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'validDate': validDate,
      'createdAt': createdAt,
      'activated_by': activatedBy,
    };
  }

  factory UserLicencesModel.fromMap(Map<String, dynamic> map) {
    return UserLicencesModel(
      userId: map['userId'] as String,
      validDate: map['validDate'] as String,
      createdAt: map['createdAt'] as String,
      activatedBy: map['activated_by'] as int,
    );
  }
}
