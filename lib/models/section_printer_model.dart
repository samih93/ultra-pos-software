// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

class SectionPrinterModel {
  final SectionType sectionType;
  final String printerName;

  SectionPrinterModel({
    required this.sectionType,
    required this.printerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'sectionType': sectionType.name,
      'printerName': printerName,
    };
  }

  factory SectionPrinterModel.fromMap(Map<String, dynamic> map) {
    return SectionPrinterModel(
      sectionType: map["sectionType"].toString().sectionTypeToEnum(),
      printerName: map['printerName'],
    );
  }

  SectionPrinterModel copyWith({
    SectionType? sectionType,
    String? printerName,
  }) {
    return SectionPrinterModel(
      sectionType: sectionType ?? this.sectionType,
      printerName: printerName ?? this.printerName,
    );
  }

  @override
  bool operator ==(covariant SectionPrinterModel other) {
    if (identical(this, other)) return true;

    return other.sectionType == sectionType && other.printerName == printerName;
  }

  @override
  int get hashCode => sectionType.hashCode ^ printerName.hashCode;
}
