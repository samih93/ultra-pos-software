import 'dart:io';

import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/error_screen.dart';
import 'package:desktoppossystem/screens/license_screen/license_screen.dart';
import 'package:desktoppossystem/screens/login/login_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/app_configuration.dart';
import 'package:desktoppossystem/shared/services/app_preferences.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/services/file_logger.dart';
import 'package:desktoppossystem/shared/services/securePreference.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/app_version.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  initState() {
    super.initState();
    AppConstance.isFullScreen = ref
        .read(appPreferencesProvider)
        .getBool(key: "isFullScreen");
    _initQuiver();
  }

  _initQuiver() async {
    try {
      await FileLogger().log('═══ Splash Screen Initialization Started ═══');
      String versionCode = await AppVersion.versionCode;
      String versionName = await AppVersion.versionName;
      appVersion = "$versionName.$versionCode";
      await FileLogger().log('App version: $appVersion');

      await FileLogger().log(
        'Calling AppConfiguration.prepareConfiguration...',
      );
      await AppConfiguration.prepareConfiguration(ref);
      await FileLogger().log('AppConfiguration completed');

      globalAppWidgetRef.read(settingControllerProvider);
      //! to remove
      globalAppWidgetRef
          .read(appPreferencesProvider)
          .removeDatabykey(key: "storedColor");

      await FileLogger().log('Waiting 2 seconds before license check...');
      await Future.delayed(const Duration(seconds: 2)).then((value) async {
        // check system license
        await FileLogger().log('Starting license check...');
        await checkLicense().then((widget) {
          if (globalAppContext.mounted) {
            globalAppContext.off(widget);
          } else {
            ToastUtils.showToast(
              message: "Context is no longer valid, widget has been disposed.",
              type: RequestState.error,
            );
          }
        });
      });
      await FileLogger().log('═══ Splash Screen Initialization Completed ═══');
    } catch (e, stackTrace) {
      await FileLogger().logError(
        'ERROR in splash screen initialization',
        e,
        stackTrace,
      );
      // Show error screen with log file path
      final logDirectory = Platform.isWindows
          ? path.dirname(Platform.resolvedExecutable)
          : (await getApplicationDocumentsDirectory()).path;
      final logFilePath = path.join(
        logDirectory,
        'logs',
        'ultra_pos_${DateFormat('yyyyMMdd').format(DateTime.now())}.log',
      );

      if (globalAppContext.mounted) {
        globalAppContext.off(
          ErrorScreen(errorText: 'Failed to initialize application: $e'),
        );
      }
    }
  }

  Future<Widget> checkLicense({int retryCount = 0}) async {
    final securePrefs =
        globalAppWidgetRef.read(securePreferencesProvider) as SecurePreferences;
    final sharedPrefs =
        globalAppWidgetRef.read(appPreferencesProvider) as AppPreferences;
    //     bool secureFileExisit = await isSecureStorageFilePresentOnWindows();
    //     if (!secureFileExisit) {
    //       // !activate after testing
    // //      sharedPrefs.removeDatabykey(key: SecureConfig.validDateKey);
    //       return const LicenseScreen();
    //     }

    try {
      // ❗ First check if license was already marked as expired due to tampering
      final isLicenseExpired = sharedPrefs.getData(
        key: SecureConfig.licenseKey,
      );
      // check if valid date exist so he remove the license key so return to licese screen
      final currentLaunchTime = sharedPrefs.getData(
        key: SecureConfig.launchTimeKey,
      );
      try {
        if (isLicenseExpired == null && currentLaunchTime != null) {
          return const LicenseScreen();
        }
        final licenseVal = isLicenseExpired != null
            ? SecureConfig.deObfuscateCoreManagerKeys(isLicenseExpired)
            : "false";
        if (licenseVal == "true") {
          debugPrint("License previously marked as expired due to tampering.");
          return const LicenseScreen();
        }
      } catch (e) {
        debugPrint("failed to load License status");
        return const LicenseScreen();
      }
      //  ❗ Fetch secure valid date
      String? validDateValue = await securePrefs.getData(key: "validDate");

      DateTime? validDate = DateTime.tryParse(validDateValue ?? '');
      debugPrint("secure valid date $validDate");

      // Handle case where validDate could not be parsed
      if (validDate == null) {
        //try to read from shared preference
        try {
          //❗this is case : fetch valid secure failed
          // ❗ fetch valid date from shared
          final sharedValue = sharedPrefs
              .getData(key: SecureConfig.validDateKey)
              ?.toString();
          final deobfuscated = sharedValue != null
              ? SecureConfig.deObfuscateCoreManagerKeys(sharedValue)
              : "";
          validDate = DateTime.tryParse(deobfuscated);
          if (validDate == null) {
            await sharedPrefs.saveData(
              key: SecureConfig.licenseKey,
              value: SecureConfig.trueKey,
            );
            return const LicenseScreen();
          }
          debugPrint("Fallback validDate from shared prefs: $validDate");
        } catch (e) {
          // if deobfuscate failed , something edited manually
          debugPrint("Fallback validDate from shared prefs failed ");
          await sharedPrefs.removeDatabykey(key: SecureConfig.validDateKey);
          await sharedPrefs.saveData(
            key: SecureConfig.licenseKey,
            value: SecureConfig.trueKey,
          );
          return const LicenseScreen();
        }
      }
      //❗ Load lastLaunchTime from secure storage or fallback to shared prefs
      String? lastLaunchTime = await securePrefs.getData(key: 'lastLaunchTime');
      debugPrint("secure launch time $lastLaunchTime");

      try {
        //! if failed load from normal shared
        lastLaunchTime ??=
            sharedPrefs.getData(
                  key: SecureConfig.deObfuscateCoreManagerKeys(
                    SecureConfig.launchTimeKey,
                  ),
                ) !=
                null
            ? SecureConfig.deObfuscateCoreManagerKeys(
                sharedPrefs.getData(key: 'lastLaunchTime'),
              )
            : null;
      } catch (e) {
        debugPrint("Fallback launch time from shared prefs ");

        await sharedPrefs.saveData(
          key: SecureConfig.licenseKey,
          value: SecureConfig.trueKey,
        );
        return const LicenseScreen();
      }

      // Default fallback if still null: now - 2 minutes
      final fallbackTime = DateTime.now().subtract(const Duration(minutes: 2));
      final lastOpened =
          DateTime.tryParse(lastLaunchTime ?? fallbackTime.toIso8601String()) ??
          fallbackTime;

      final now = DateTime.now();
      debugPrint("lastOpened: $lastOpened, now: $now");

      // If current system time is before last opened → user tampered clock
      if (now.isBefore(lastOpened)) {
        return ErrorScreen(
          errorText: "System time issue detected. Please check your clock.",
          retry: _initQuiver,
        );
      }

      // License expired?
      if (validDate.isBefore(now)) {
        await securePrefs.saveData(
          key: "validDate",
          value: validDate.toString(),
        );
        sharedPrefs.saveData(
          key: SecureConfig.licenseKey,
          value: SecureConfig.trueKey,
        );
        sharedPrefs.removeDatabykey(key: SecureConfig.validDateKey);
        return const LicenseScreen();
      }
      // Store current time as lastLaunchTime in both storages
      final nowIso = now.toIso8601String();
      await securePrefs.saveData(key: 'lastLaunchTime', value: nowIso);
      sharedPrefs.saveData(
        key: SecureConfig.launchTimeKey,
        value: SecureConfig.obfuscateCoreManagerKeys(nowIso),
      );

      UserModel? user;
      try {
        user = await securePrefs.getUser();
      } catch (e) {
        debugPrint("User fetch error: $e");
        return const LoginScreen();
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // If user exists, set the appropriate initial screen based on role and settings
      handleInitialScreenForMobile(user, sharedPrefs);

      return user != null ? MainScreen() : const LoginScreen();
    } catch (e) {
      // Handle any errors that occurred during the process
      debugPrint("Error in checkLicense: ${e.toString()}");
      return ErrorScreen(
        retry: () {
          _initQuiver(); // Retry logic
        },
      );
    }
  }

  void handleInitialScreenForMobile(
    UserModel? user,
    AppPreferences sharedPrefs,
  ) {
    // If user exists, set the appropriate initial screen based on role and settings
    if (user != null) {
      final isOwner = user.id == int.tryParse(SecureConfig.quiverUserId);
      final isMobile = globalAppContext.isMobile;
      final onlyActivatedMenu = sharedPrefs.getSecureBool(
        key: SecureConfig.onlyActivateMenuKey,
        defaultValue: false,
      );
      final menuActivated = sharedPrefs.getSecureBool(
        key: SecureConfig.activateMenuKey,
        defaultValue: false,
      );

      // Set initial screen based on role and device
      if (isMobile && !isOwner) {
        // Mobile non-owner logic
        if (onlyActivatedMenu && menuActivated) {
          // Only menu mode - go to online menu
          globalAppWidgetRef
              .read(currentMainScreenProvider.notifier)
              .update((state) => ScreenName.OnlineMenuScreen);
        }
      }
      // Desktop or owner will use default screen from main_controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    return Scaffold(
      backgroundColor: context.cardColor,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            ref.read(isDarkModeProvider)
                ? AssetConstant.coreWhiteLogoWithName
                : AssetConstant.splashImage,
            fit: BoxFit.cover,
          ),
        ),
      ),
      // body: Center(
      //     child: DefaultTextView(
      //   text: "QuiverⓇ",
      //   fontsize: 120,
      //   color: Colors.white,
      // )),
    );
  }
}
