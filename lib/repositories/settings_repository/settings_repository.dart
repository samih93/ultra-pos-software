import 'dart:convert';

import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/setting_model.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final settingProviderRepository = Provider((ref) {
  return SettingsRepository(ref);
});

abstract class ISettingsRepository {
  FutureEither<SettingModel> fetchSettings();
  FutureEither<SettingModel> addSettings(SettingModel s);
  FutureEither<SettingModel> updateSettings({required SettingModel s});
  FutureEither<String> executeQuery(String query);
}

class SettingsRepository implements ISettingsRepository {
  final Ref ref;
  SettingsRepository(this.ref);
  @override
  FutureEither<SettingModel> fetchSettings() async {
    try {
      SettingModel settingModel = SettingModel();

      await ref.read(posDbProvider).database.query(TableConstant.settings).then(
        (response) {
          if (response.isNotEmpty) {
            settingModel = SettingModel.fromMap(response[0]);
          }
        },
      );

      return right(settingModel);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<SettingModel> addSettings(SettingModel s) async {
    try {
      SettingModel settingModel = SettingModel();
      await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.settings, s.toMap())
          .then((value) {
            settingModel = s;
            settingModel.id = value;
          })
          .catchError((error) {
            throw Exception(error);
          });
      return right(settingModel);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<SettingModel> updateSettings({required SettingModel s}) async {
    try {
      SettingModel settingModel = SettingModel();

      await ref
          .read(posDbProvider)
          .database
          .update(TableConstant.settings, s.toMap(), where: " id=${s.id}")
          .then((value) {
            settingModel = s;
          })
          .catchError((error) {
            throw Exception(error);
          });
      return right(settingModel);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<String> executeQuery(String query) async {
    final db = ref.read(posDbProvider).database;
    final normalizedQuery = query.trim().toUpperCase();
    final isDelete = normalizedQuery.startsWith('DELETE');

    try {
      // Execute the main query in a transaction
      final result = await db.transaction((txn) async {
        final response = await txn.rawQuery(query);
        return jsonEncode(response.toString());
      });

      // Only vacuum after DELETE operations that might free space
      debugPrint("is Delete $isDelete");
      if (isDelete) {
        try {
          // Add a small delay to prevent immediate locking after transaction
          await Future.delayed(const Duration(milliseconds: 100));
          await db.execute('VACUUM');
        } catch (e) {
          // Log vacuum failure but don't fail the original operation
          debugPrint('VACUUM failed: ${e.toString()}');
          return left(FailureModel('VACUUM failed: ${e.toString()}'));
        }
      }

      return right(result);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
