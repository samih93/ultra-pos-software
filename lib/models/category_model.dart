// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

class CategoryModel {
  int? id;
  String? name;
  String? color;
  // String? textcolor;
  bool? selected = false;
  int? sort;
  SectionType? sectionType;
  bool? hideOnMenu;
  int? productsCount;

  CategoryModel({
    this.id,
    required this.name,
    required this.color,
    // required this.textcolor,
    required this.selected,
    this.sort,
    this.sectionType,
    this.hideOnMenu = false,
    this.productsCount = 0,
  });

  CategoryModel.second();

  factory CategoryModel.fromJson(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'].toString(),
      color: map['color'],
      //  textcolor: map['textColor'],
      selected: map['selected'] ?? false,
      sectionType: map['sectionType'].toString().sectionTypeToEnum(),
      hideOnMenu: map['hideOnMenu'].toString().validateBool(),
      sort: map['sort'] != null ? map['sort'] as int : 0,
      productsCount: map['productsCount'] ?? 0,
    );
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      // 'textColor': textcolor,
      // 'selected': selected == true ? 1 : 0
    };
  }

  toJsonWithoutId() {
    return {
      'name': name,
      'color': color,
      'sort': sort,
      'section': sectionType != null
          ? sectionType!.name
          : SectionType.kitchen.name,
      // 'textColor': textcolor,
    };
  }

  toJsonForMenu() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'sort': sort,
      'hideOnMenu': hideOnMenu == true ? 1 : 0,
    };
  }

  toJsonForSorting() {
    return {'id': id, 'sort': sort};
  }

  @override
  bool operator ==(covariant CategoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.color == color &&
        other.selected == selected &&
        other.sort == sort &&
        other.sectionType == sectionType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        color.hashCode ^
        selected.hashCode ^
        sort.hashCode ^
        sectionType.hashCode;
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? color,
    bool? selected,
    int? sort,
    bool? hideOnMenu,
    SectionType? sectionType,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      selected: selected ?? this.selected,
      sort: sort ?? this.sort,
      hideOnMenu: hideOnMenu ?? this.hideOnMenu,
      sectionType: sectionType ?? this.sectionType,
    );
  }
}
