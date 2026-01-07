// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:desktoppossystem/models/opening_hours_model.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:image/image.dart' as img;

class SettingModel {
  int? id;
  Uint8List? logo;
  String? storeName;
  String? storeLocation;
  String? storePhone;
  String? storeQrCode;
  Currency? primaryCurrency;
  Currency? secondaryCurrency;
  double? dolarRate;
  bool? printLogoOnInvoice;
  String? note;
  String? telegramChatId;
  List<OpeningHoursModel>? openingHours;

  SettingModel({
    this.id,
    this.logo,
    this.storeName,
    this.storeLocation,
    this.storePhone,
    this.storeQrCode,
    this.primaryCurrency,
    this.secondaryCurrency,
    this.dolarRate,
    this.printLogoOnInvoice,
    this.note,
    this.telegramChatId,
    this.openingHours,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'logo': logo,
      'storeName': storeName,
      'storeLocation': storeLocation,
      'storePhone': storePhone,
      'storeQrCode': storeQrCode,
      'dolarRate': dolarRate,
      'note': note,
      'primaryCurrency': primaryCurrency != null
          ? primaryCurrency!.name
          : Currency.USD.name,
      'secondaryCurrency': secondaryCurrency != null
          ? secondaryCurrency!.name
          : Currency.LBP.name,
      'printLogoOnInvoice': printLogoOnInvoice == true ? 1 : 0,
      'openingHours': openingHours != null
          ? OpeningHoursModel.encodeList(openingHours!)
          : null,
    };
  }

  factory SettingModel.fromMap(Map<String, dynamic> map) {
    return SettingModel(
      id: map['id'] != null ? map['id'] as int : null,
      logo: map['logo'],
      storeName: map['storeName'] != null ? map['storeName'] as String : null,
      storeLocation: map['storeLocation'] != null
          ? map['storeLocation'] as String
          : null,
      storePhone: map['storePhone'] != null
          ? map['storePhone'] as String
          : null,
      storeQrCode: map['storeQrCode'] != null
          ? map['storeQrCode'] as String
          : null,
      note: map['note'],
      telegramChatId: map['telegramChatId'],
      primaryCurrency: map['primaryCurrency'].toString().currencyToEnum(),
      secondaryCurrency: map['secondaryCurrency'].toString().currencyToEnum(),
      dolarRate: map['dolarRate'],
      printLogoOnInvoice: map['printLogoOnInvoice'] != null
          ? map['printLogoOnInvoice'] == 1
                ? true
                : false
          : false,
    );
  }

  factory SettingModel.fromJsonMenu(Map<String, dynamic> map) {
    return SettingModel(
      id: map['id'] != null ? map['id'] as int : null,
      logo: convertImageData(map['logo']),
      storeName: map['storeName'] != null ? map['storeName'] as String : null,
      storeLocation: map['storeLocation'] != null
          ? map['storeLocation'] as String
          : null,
      storePhone: map['storePhone'] != null
          ? map['storePhone'] as String
          : null,

      note: map['note'],
      primaryCurrency: map['primaryCurrency'].toString().currencyToEnum(),
      secondaryCurrency: map['secondaryCurrency'].toString().currencyToEnum(),
      dolarRate: double.tryParse(map['dolarRate'].toString()) ?? 0.0,
      openingHours: OpeningHoursModel.parseList(map['openingHours']),
    );
  }

  toJsonMenu() {
    // Compress image if it exists
    String compressedImageData = '';
    if (logo != null && logo!.isNotEmpty) {
      try {
        // Decode the logo
        img.Image? decodedImage = img.decodeImage(logo!);
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
          compressedImageData = base64Encode(logo!);
        }
      } catch (e) {
        // If compression fails, use original
        compressedImageData = base64Encode(logo!);
      }
    }
    return <String, dynamic>{
      'id': id,
      'logo': logo != null ? compressedImageData : null,
      'storeName': storeName,
      'storeLocation': storeLocation,
      'storePhone': storePhone,
      'dolarRate': dolarRate,
      'note': note,
      'primaryCurrency': primaryCurrency != null
          ? primaryCurrency!.name
          : Currency.USD.name,
      'secondaryCurrency': secondaryCurrency != null
          ? secondaryCurrency!.name
          : Currency.LBP.name,
      'openingHours': openingHours != null
          ? OpeningHoursModel.encodeList(openingHours!)
          : null,
    };
  }

  SettingModel copyWith({
    int? id,
    Uint8List? logo,
    String? storeName,
    String? storeLocation,
    String? storePhone,
    String? storeQrCode,
    String? note,
    String? telegramChatId,
    Currency? primaryCurrency,
    Currency? secondaryCurrency,
    double? dolarRate,
    bool? printLogoOnInvoice,
    List<OpeningHoursModel>? openingHours,
  }) {
    return SettingModel(
      id: id ?? this.id,
      logo: logo ?? this.logo,
      storeName: storeName ?? this.storeName,
      storeLocation: storeLocation ?? this.storeLocation,
      storePhone: storePhone ?? this.storePhone,
      storeQrCode: storeQrCode ?? this.storeQrCode,
      note: note ?? this.note,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      secondaryCurrency: secondaryCurrency ?? this.secondaryCurrency,
      dolarRate: dolarRate ?? this.dolarRate,
      printLogoOnInvoice: printLogoOnInvoice ?? this.printLogoOnInvoice,
      openingHours: openingHours ?? this.openingHours,
    );
  }
}
