import 'dart:convert';

import 'package:desktoppossystem/models/license_settings_model.dart';
import 'package:desktoppossystem/repositories/licenses/i_license_repository.dart';
import 'package:desktoppossystem/repositories/licenses/license_repository.dart';
import 'package:desktoppossystem/screens/login/login_screen.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final remainingLicenseDaysProvider = FutureProvider<int>((ref) async {
  final v = await ref.read(securePreferencesProvider).getData(key: "validDate");
  final validDate = DateTime.tryParse(v.toString());
  if (validDate == null) throw Exception("fetch failed");
  DateTime currentDate = DateTime.now(); // Get the current date

  // Calculate the difference
  Duration difference = validDate.difference(currentDate);
  return difference.inDays;
});

final licenseControllerProvider = ChangeNotifierProvider<LicensesController>((
  ref,
) {
  return LicensesController(
    ref: ref,
    licenseRepository: ref.read(licenseProviderRepository),
  );
});

class LicensesController extends ChangeNotifier {
  final Ref _ref;
  final ILicenseRepository _licenseRepository;
  LicensesController({
    required Ref ref,
    required ILicenseRepository licenseRepository,
  }) : _ref = ref,
       _licenseRepository = licenseRepository;

  RequestState activateRequestState = RequestState.success;

  void _applyLicenseSettings(LicenseSettingsModel settings) {
    // Always save menu activation state
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: SecureConfig.activateMenuKey,
          value: settings.activateMenu
              ? SecureConfig.trueKey
              : SecureConfig.falseKey,
        );
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: SecureConfig.onlyActivateMenuKey,
          value: settings.onlyActivateMenu
              ? SecureConfig.trueKey
              : SecureConfig.falseKey,
        );
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: SecureConfig.subscriptionKey,
          value: settings.activateSubscription
              ? SecureConfig.trueKey
              : SecureConfig.falseKey,
        );
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "showShift", value: settings.showShift);
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: "showRestaurantStock",
          value: settings.workWithIngredients,
        );

    _ref
        .read(appPreferencesProvider)
        .saveData(key: "screenUI", value: settings.screenUI);
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: SecureConfig.onlyActivateMenuKey,
          value: settings.onlyActivateMenu
              ? SecureConfig.trueKey
              : SecureConfig.falseKey,
        );

    // Only handle onlyActivatedMenu if menu is activated
    if (settings.activateMenu) {
      _ref
          .read(appPreferencesProvider)
          .saveData(
            key: SecureConfig.onlyActivateMenuKey,
            value: settings.onlyActivateMenu
                ? SecureConfig.trueKey
                : SecureConfig.falseKey,
          );
    } else {
      // Clear onlyActivatedMenu when menu is deactivated
      _ref
          .read(appPreferencesProvider)
          .saveData(
            key: SecureConfig.onlyActivateMenuKey,
            value: SecureConfig.falseKey,
          );
    }
  }

  Future activateApp(String license, BuildContext context) async {
    activateRequestState = RequestState.loading;
    notifyListeners();
    try {
      AuthResponse authResponse = await signInSilently();

      if (authResponse.user != null) {
        var res = await _licenseRepository.activateApp(license);

        res.fold(
          (l) {
            activateRequestState = RequestState.error;
            notifyListeners();
            ToastUtils.showToast(type: RequestState.error, message: l.message);
          },
          (r) async {
            final serverSettings = LicenseSettingsModel.fromMap(
              jsonDecode(r["serverSettings"] as String) as Map<String, dynamic>,
            );

            _applyLicenseSettings(serverSettings);

            await _ref
                .read(securePreferencesProvider)
                .saveData(key: "validDate", value: r["validDate"]);

            await _ref
                .read(securePreferencesProvider)
                .saveData(
                  key: 'lastLaunchTime',
                  value: DateTime.now().toIso8601String(),
                );
            _ref
                .read(securePreferencesProvider)
                .saveData(key: "registrationUserId", value: r["userId"]);

            final encryptedValiddate = SecureConfig.obfuscateCoreManagerKeys(
              r["validDate"].toString(),
            );
            final encryptedLaunchTime = SecureConfig.obfuscateCoreManagerKeys(
              DateTime.now().toString(),
            );
            final isLicensedExpired = SecureConfig.falseKey;
            Future.wait([
              _ref
                  .read(appPreferencesProvider)
                  .saveData(
                    key: SecureConfig.validDateKey,
                    value: encryptedValiddate,
                  ),
              _ref
                  .read(appPreferencesProvider)
                  .saveData(
                    key: SecureConfig.launchTimeKey,
                    value: encryptedLaunchTime,
                  ),
              // is Licensed
              _ref
                  .read(appPreferencesProvider)
                  .saveData(
                    key: SecureConfig.licenseKey,
                    value: isLicensedExpired,
                  ),
            ]);

            ToastUtils.showToast(
              message: "Activation Successfully till '${r["validDate"]}'",
            );
            _ref.read(supaBaseProvider).auth.signOut();

            context.off(const LoginScreen());
            activateRequestState = RequestState.success;
            notifyListeners();
          },
        );
      }
    } catch (e) {
      print(e.toString());
      ToastUtils.showToast(
        type: RequestState.error,
        message: "Invalid Authentication",
        duration: const Duration(seconds: 4),
      );
      activateRequestState = RequestState.error;
      notifyListeners();
      return;
    }
  }
}
