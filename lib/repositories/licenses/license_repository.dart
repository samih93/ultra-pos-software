import 'dart:convert';

import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/license_settings_model.dart';
import 'package:desktoppossystem/models/user_licence_model.dart';
import 'package:desktoppossystem/repositories/licenses/i_license_repository.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final licenseProviderRepository = Provider((ref) {
  return LicenseRepository(ref);
});

class LicenseRepository implements ILicenseRepository {
  final Ref ref;
  LicenseRepository(this.ref);
  @override
  FutureEither<Map<String, String>> activateApp(String license) async {
    try {
      final data = await ref
          .read(supaBaseProvider)
          .from('licenses')
          .select('validDate,for_user ,partner_id , settings')
          .eq('license', license)
          .eq("active", 'TRUE');
      if ((data as List).isEmpty) {
        return left(FailureModel("invalid license"));
      } else {
        // ! check if valid date
        if (DateTime.parse(
          data[0]["validDate"].toString(),
        ).isAfter(DateTime.parse(DateTime.now().toString().split(' ').first))) {
          //! save the validation for the user Id
          final insertActivationInfo = await saveActivationInfo(
            UserLicencesModel(
              userId: data[0]['for_user'].toString(),
              validDate: data[0]["validDate"],
              createdAt: DateTime.now().toString(),
              activatedBy: data[0]["partner_id"],
            ),
          );
          insertActivationInfo.fold((l) => throw Exception(l.message), (
            r,
          ) async {
            // ! SET THE LICENSE ACTIVE TO FALSE
            final disableL = await disableLicense(license);
            disableL.fold((l) => throw Exception(l.message), (r) => null);
          });

          final settings = {
            ...LicenseSettingsModel.defaultJsonSetting(),
            ...data[0]['settings'] ?? {},
          };

          return Right({
            "validDate": data[0]["validDate"],
            "userId": data[0]['for_user'].toString(),
            "serverSettings": jsonEncode(settings),
          });
        } else {
          return left(FailureModel("Licence Expired"));
        }
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid saveActivationInfo(
    UserLicencesModel userLicencesModel,
  ) async {
    try {
      await ref
          .read(supaBaseProvider)
          .from('usersLicenses')
          .insert(userLicencesModel.toMap());
      return right(null);
    } catch (e) {
      debugPrint(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid disableLicense(String license) async {
    try {
      await ref
          .read(supaBaseProvider)
          .from('licenses')
          .update({'active': 'FALSE', 'version': appVersion})
          .match({'license': license});
      return right(null);
    } catch (e) {
      debugPrint(e.toString());
      return left(FailureModel(e.toString()));
    }
  }
}
