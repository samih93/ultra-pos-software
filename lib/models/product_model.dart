// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:desktoppossystem/models/ingrendient_model.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ProductModel {
  int? id;
  String? name;
  double? originalSellingPrice;
  double? oldCostPrice;
  double? oldSellingPrice;
  double? sellingPrice;
  double? secondarySellingPrice; //! for ui only
  bool? sellingInPrimary = true; //! for ui only
  double? minSellingPrice;
  double? profitRate;
  double? costPrice;
  double? newAverageCost;
  double? qty;
  double? oldQty;
  //! used for market sale screen
  double? qtyInStock;
  // user for restaurant
  double? countsAsItem;
  String? barcode;
  bool? selected;
  bool? isNewToBasket = false;
  bool? isJustOrdered = false;
  bool? isAlreadyOrdered = false;
  String? tableName;
  List<IngredientModel>? ingredients = [];
  String notes = "";
  List<IngredientModel>? withoutIngredients = [];
  List<IngredientModel> ingredientsToBeAdded = [];
  //! double? heightDataRow = 0;
  int? categoryId;
  String? expiryDate;
  Color? categoryColor;

  //! id of record in table product
  int? productTableId;

  bool? isActive = true;
  double? discount = 0;

  double? warningAlert;

  // //! for offer
  // bool? isOffer;
  // int? offerProductId;
  // int? offerQty;

  bool? isTracked = false;
  bool? enableNotification = false;

  // ! for print an old invoice has refunded items
  bool? isRefunded = false;

  // IMAGE
  Uint8List? image;

  SectionType? sectionType;
  int? categorySort;
  int? sortOrder;

  bool? isWeighted;
  double? weight;
  int? plu;
  bool? isOffer;
  String? description;
  bool get isLowStock {
    if (qty != null && warningAlert != null) {
      return qty! <= warningAlert! && enableNotification == true;
    }
    return false;
  }

  String? categoryName;
  ProductModel({
    required this.id,
    required this.name,
    this.originalSellingPrice,
    required this.sellingPrice,
    this.secondarySellingPrice,
    this.sellingInPrimary,
    this.minSellingPrice,
    this.profitRate,
    this.costPrice,
    this.newAverageCost,
    this.oldCostPrice,
    this.oldSellingPrice,
    this.qty,
    this.oldQty,
    this.qtyInStock = 0,
    this.barcode,
    required this.selected,
    required this.categoryId,
    this.categoryName,
    this.tableName,
    this.isNewToBasket,
    this.productTableId,
    this.expiryDate,
    this.isTracked,
    this.enableNotification,
    this.isActive,
    this.countsAsItem,
    this.discount,
    // to fetch products inserted to table
    this.ingredients,
    this.withoutIngredients = const [],
    this.image,
    this.warningAlert,
    this.categoryColor,
    this.sectionType,
    this.categorySort,
    this.sortOrder,
    this.isWeighted,
    this.plu,
    this.isOffer,
    this.description = "",
  });

  ProductModel.second();

  factory ProductModel.fromJson(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'].toString(),
      sellingPrice: double.tryParse(map['price'].toString()) ?? 0,
      minSellingPrice: double.tryParse(map['minSellingPrice'].toString()) ?? 0,
      originalSellingPrice: double.tryParse(map['price'].toString()) ?? 0,
      costPrice: double.tryParse(map['costPrice'].toString()) ?? 0,
      profitRate: double.tryParse(map['profitRate'].toString()) ?? 0,
      qty: double.tryParse(map["qty"].toString()) ?? 0,
      barcode: map['barcode'] ?? '',
      selected: map['selected'] == 1 ? true : false,
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      categoryColor: map['color'] != null
          ? map['color'].toString().getColorFromHex()
          : Pallete.redColor,
      sectionType: map['sectionType'].toString().sectionTypeToEnum(),
      expiryDate: map['expiryDate'] ?? '',
      isTracked: map['isTracked'] != null
          ? map['isTracked'] == 1
                ? true
                : false
          : false,
      enableNotification: map['enableNotification'] != null
          ? map['enableNotification'] == 1
                ? true
                : false
          : false,
      isActive: map['isActive'] != null
          ? map['isActive'] == 1
                ? true
                : false
          : true,
      isOffer: map['isOffer'] != null
          ? map['isOffer'] == 1
                ? true
                : false
          : false,
      discount: map['discount'] ?? 0,
      image: map['image'],
      warningAlert: map['warningAlert'] ?? 1,
      categorySort: map['categorySort'] ?? 0,
      sortOrder: map['sortOrder'] ?? 0,
      isWeighted: map['isWeighted'] == 1 ? true : false,
      plu: map['plu'],
      description: map['description'] ?? '',
    );
  }
  factory ProductModel.fromTableJson(Map<String, dynamic> map) {
    return ProductModel(
      id: map['productId'],
      name: null,
      qty: double.tryParse(map["qty"].toString()) ?? 0,
      tableName: map['tableName'].toString(),
      sellingPrice: null,
      selected: null,
      categoryId: null,
    );
  }

  factory ProductModel.fromJsonForMenu(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'].toString(),
      sellingPrice: double.tryParse(map['price'].toString()) ?? 0,
      isActive: map['isActive'] != null
          ? map['isActive'] == 1
                ? true
                : false
          : true,
      sortOrder: map['sortOrder'] ?? 50,
      categoryId: map['categoryId'],
      description: map['description'] ?? '',
      image: convertImageData(map['image']),
      isOffer: map['isOffer'] != null
          ? map['isOffer'] == 1
                ? true
                : false
          : false,
      selected: null,
    );
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'price': sellingPrice,
      'costPrice': costPrice,
      'qty': qty,
      'barcode': barcode,
      'selected': selected,
      'categoryId': categoryId,
      'description': description,
      // 'notesAvailable': notesAvailable.map((e) => e.note),
    };
  }

  toJsonWithoutNote() {
    return {
      'id': id,
      'name': name,
      'originalSellingPrice': originalSellingPrice,
      'price': sellingPrice,
      'costPrice': costPrice,
      'qty': qty,
      'barcode': barcode,
      'selected': selected,
      'categoryId': categoryId,
      'discount': discount,
      'sectionType': sectionType,
    };
  }

  toJsonWithoutId() {
    return {
      'name': name,
      'price': sellingPrice ?? 0,
      'costPrice': costPrice ?? 0,
      'minSellingPrice': minSellingPrice ?? 0,
      'profitRate': profitRate ?? 0,
      'barcode': barcode != null ? barcode!.toUpperCase() : '',
      'qty': qty ?? 0,
      'categoryId': categoryId,
      'expiryDate': expiryDate,
      'isTracked': isTracked == true ? 1 : 0,
      'enableNotification': enableNotification == true ? 1 : 0,
      'isActive': isActive == true ? 1 : 0,
      'countsAsItem': countsAsItem ?? 1,
      'discount': discount ?? 0,
      'image': image,
      'warningAlert': warningAlert,
      'sortOrder': sortOrder ?? 50,
      "isWeighted": isWeighted == true ? 1 : 0,
      "isOffer": isOffer == true ? 1 : 0,
      "plu": isWeighted == true ? plu ?? 0 : null,
      'description': description,
    };
  }

  toJsonForTables() {
    return {
      'productId': id,
      'tableName': tableName,
      'productName': name,
      'qty': qty,
      'price': sellingPrice,
      'costPrice': costPrice,
      'countsAsItem': countsAsItem ?? 1,
      'ingredients': jsonEncode([
        ...ingredients!.map((e) => e.toMapForTable()),
      ]),
      'withoutIngredients': jsonEncode([
        ...withoutIngredients!.map((e) => e.toMapForTable()),
      ]),
    };
  }

  factory ProductModel.fromJsonTables(Map<String, dynamic> map) {
    return ProductModel(
      id: map['productId'],
      tableName: map['tableName'].toString(),
      sellingPrice: double.tryParse(map['price'].toString()) ?? 0,
      originalSellingPrice: double.tryParse(map['price'].toString()) ?? 0,
      costPrice: double.tryParse(map['costPrice'].toString()) ?? 0,
      qty: double.tryParse(map['qty'].toString()) ?? 0,
      countsAsItem: double.tryParse(map['countsAsItem'].toString()) ?? 1,
      isNewToBasket: false,
      name: map['productName'].toString(),
      selected: false,
      categoryId: 0,
      discount: 0,
      productTableId: map["id"],
      ingredients: map["ingredients"] != null
          ? List.from(
              jsonDecode(
                map["ingredients"],
              ).map((e) => IngredientModel.fromMap(e)),
            )
          : [],
      withoutIngredients: map["withoutIngredients"] != null
          ? List.from(
              jsonDecode(
                map["withoutIngredients"],
              ).map((e) => IngredientModel.fromMap(e)),
            )
          : [],
    );
  }

  ProductModel copyWith({
    int? id,
    String? name,
    double? sellingPrice,
    double? secondarySellingPrice,
    bool? sellingInPrimary,
    double? minSellingPrice,
    double? originalSellingPrice,
    double? costPrice,
    double? newAverageCost,
    double? oldCostPrice,
    double? oldSellingPrice,
    double? qty,
    double? oldQty,
    double? qtyInStock,
    String? barcode,
    bool? selected,
    int? categoryId,
    double? discount,
    double? profitRate,
    bool? isActive,
    bool? isTracked,
    Uint8List? image,
    bool? enableNotification,
    String? expiryDate,
    Color? categoryColor,
    int? categorySort,
    int? sortOrder,
    double? warningAlert,
    String? description,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      secondarySellingPrice:
          secondarySellingPrice ?? this.secondarySellingPrice,
      sellingInPrimary: sellingInPrimary ?? this.sellingInPrimary,
      minSellingPrice: minSellingPrice ?? this.minSellingPrice,
      originalSellingPrice: originalSellingPrice ?? this.sellingPrice,
      newAverageCost: newAverageCost ?? this.newAverageCost,
      costPrice: costPrice ?? this.costPrice,
      oldCostPrice: oldCostPrice ?? this.oldCostPrice,
      oldSellingPrice: oldSellingPrice ?? this.oldSellingPrice,
      qty: qty ?? this.qty,
      oldQty: oldQty ?? this.oldQty,
      qtyInStock: qtyInStock ?? this.qtyInStock,
      barcode: barcode ?? this.barcode,
      selected: false,
      categoryId: categoryId ?? this.categoryId,
      discount: discount ?? this.discount,
      profitRate: profitRate ?? this.profitRate,
      isTracked: isTracked ?? this.isTracked,
      enableNotification: enableNotification ?? this.enableNotification,
      warningAlert: warningAlert ?? this.warningAlert,
      expiryDate: expiryDate ?? this.expiryDate,
      categoryColor: categoryColor ?? this.categoryColor,
      categorySort: categorySort ?? this.categorySort,
      sortOrder: sortOrder ?? this.sortOrder,
      image: image ?? this.image,
      description: description ?? this.description,
    );
  }

  ProductModel cloneWithoutId({
    int? id,
    String? name,
    double? sellingPrice,
    double? secondarySellingPrice,
    bool? sellingInPrimary,
    double? minSellingPrice,
    double? originalSellingPrice,
    double? costPrice,
    double? newAverageCost,
    double? oldCostPrice,
    double? oldSellingPrice,
    double? qty,
    double? oldQty,
    double? qtyInStock,
    String? barcode,
    bool? selected,
    int? categoryId,
    double? discount,
    double? profitRate,
    bool? isActive,
    bool? isTracked,
    Uint8List? image,
    bool? enableNotification,
    String? expiryDate,
    Color? categoryColor,
    int? categorySort,
    int? sortOrder,
    double? warningAlert,
    String? description,
  }) {
    return ProductModel(
      id: null,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      secondarySellingPrice:
          secondarySellingPrice ?? this.secondarySellingPrice,
      sellingInPrimary: sellingInPrimary ?? this.sellingInPrimary,
      minSellingPrice: minSellingPrice ?? this.minSellingPrice,
      originalSellingPrice: originalSellingPrice ?? this.sellingPrice,
      newAverageCost: newAverageCost ?? this.newAverageCost,
      costPrice: costPrice ?? this.costPrice,
      oldCostPrice: oldCostPrice ?? this.oldCostPrice,
      oldSellingPrice: oldSellingPrice ?? this.oldSellingPrice,
      qty: qty ?? this.qty,
      oldQty: oldQty ?? this.oldQty,
      qtyInStock: qtyInStock ?? this.qtyInStock,
      barcode: barcode ?? this.barcode,
      selected: false,
      categoryId: categoryId ?? this.categoryId,
      discount: discount ?? this.discount,
      profitRate: profitRate ?? this.profitRate,
      isTracked: isTracked ?? this.isTracked,
      enableNotification: enableNotification ?? this.enableNotification,
      warningAlert: warningAlert ?? this.warningAlert,
      expiryDate: expiryDate ?? this.expiryDate,
      categoryColor: categoryColor ?? this.categoryColor,
      categorySort: categorySort ?? this.categorySort,
      sortOrder: sortOrder ?? this.sortOrder,
      image: image ?? this.image,
      description: description ?? this.description,
    );
  }

  factory ProductModel.fake() {
    final random = Random();
    return ProductModel(
      warningAlert: 1,
      minSellingPrice: 3,
      categoryColor: Pallete.primaryColorDark,
      id: random.nextInt(1000),
      name: 'Product 1 asd as das ',
      originalSellingPrice: random.nextDouble() * 100,
      sellingPrice: random.nextDouble() * 100,
      profitRate: random.nextDouble() * 10,
      costPrice: random.nextDouble() * 50,
      newAverageCost: random.nextDouble() * 50,
      oldCostPrice: random.nextDouble() * 50,
      oldSellingPrice: random.nextDouble() * 100,
      qty: 5,
      oldQty: 5,
      qtyInStock: 5,
      barcode: 'sadsa',
      selected: false,
      categoryId: 1,
      expiryDate: null,
      isTracked: false,
      discount: 10,
      ingredients: [],
    );
  }

  toJsonForMenu() {
    // Compress image if it exists
    String compressedImageData = '';
    if (image != null && image!.isNotEmpty) {
      try {
        // Decode the image
        img.Image? decodedImage = img.decodeImage(image!);
        if (decodedImage != null) {
          // Resize if too large (max 300x300 for smaller payload)
          if (decodedImage.width > 300 || decodedImage.height > 300) {
            decodedImage = img.copyResize(
              decodedImage,
              width: decodedImage.width > decodedImage.height ? 300 : null,
              height: decodedImage.height >= decodedImage.width ? 300 : null,
            );
          }

          // Compress with 40% quality for smaller payload
          Uint8List compressedBytes = Uint8List.fromList(
            img.encodeJpg(decodedImage, quality: 40),
          );
          compressedImageData = base64Encode(compressedBytes);
        } else {
          // If decoding fails, use original
          compressedImageData = base64Encode(image!);
        }
      } catch (e) {
        // If compression fails, use original
        compressedImageData = base64Encode(image!);
      }
    }
    return {
      'id': id,
      'name': name,
      'price': sellingPrice,
      'isActive': isActive == true ? 1 : 0,
      'imageData': compressedImageData,
      'sortOrder': sortOrder ?? 50,
      "isOffer": isOffer == true ? 1 : 0,
      'categoryId': categoryId,
      'description': description,
    };
  }

  toJsonForMenuWithoutImage() {
    return {
      'id': id,
      'name': name,
      'price': sellingPrice,
      'isActive': isActive == true ? 1 : 0,
      'sortOrder': sortOrder ?? 50,
      "isOffer": isOffer == true ? 1 : 0,
      'categoryId': categoryId,
      'description': description,
    };
  }

  toJsonForSorting() {
    return {'id': id, 'sortOrder': sortOrder ?? 50};
  }
}
