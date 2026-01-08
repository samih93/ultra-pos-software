import 'dart:io';

import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/splash_screen/splash_screen.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/services/app_preferences.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/services/file_logger.dart';
import 'package:desktoppossystem/shared/services/my_http_override.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:toastification/toastification.dart';

//! generate translation file
//flutter pub run intl_utils:generate
final navigationKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});
void main() async {
  HttpOverrides.global = MyHttpOverrides();

  // ignore: await_only_futures
  await WidgetsFlutterBinding.ensureInitialized();

  // Initialize file logger FIRST for production error tracking
  if (Platform.isWindows) {
    try {
      await FileLogger().init();
    } catch (e) {
      debugPrint('Failed to initialize FileLogger: $e');
    }
  }

  try {
    // Initialize TerminateRestart only for mobile platforms
    if (!Platform.isWindows) {
      try {
        TerminateRestart.instance.initialize();
      } catch (e) {
        debugPrint('Failed to initialize TerminateRestart: $e');
      }
    }

    // Initialize core services (AppPreferences handles its own corruption recovery)
    await Future.wait([
      AppPreferences.init(),
      Supabase.initialize(
        url: SecureConfig.supabaseUrl,
        anonKey: SecureConfig.supabaseAnonKey,
      ),
    ]);
  } catch (e, stackTrace) {
    await FileLogger().log(
      'FATAL ERROR: $e\nStack: $stackTrace',
      level: 'ERROR',
    );
    debugPrint('FATAL ERROR: $e\n$stackTrace');
    rethrow;
  }

  runApp(
    DevicePreview(
      enabled: kDebugMode ? true : false,
      builder: (context) => const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  static late WidgetRef appRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    appRef = ref;
    var mainController = ref.watch(mainControllerProvider);

    return ScreenUtilInit(
      // Since tablets/mobiles use landscape (forced in main()),
      // use landscape design base for all devices
      // Tablets >= 600px will use full desktop UI
      // Mobiles < 600px will use scaled mobile UI
      designSize: const Size(1920, 1080), // Landscape base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ToastificationWrapper(
          child: MaterialApp(
            themeAnimationCurve: Curves.fastOutSlowIn,
            themeAnimationDuration: const Duration(milliseconds: 1500),
            navigatorKey: ref.watch(navigationKeyProvider),
            locale: Locale(mainController.selectedLanguage.name),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            debugShowCheckedModeBanner: false,
            title: 'Ultra Pos',
            theme: ref.watch(themeNotifierProvider),
            home: const ResponsiveWidget(
              desktopView: SplashScreen(),
              mobileView: SplashScreen(),
            ),
          ),
        );
      },
    );
  }
}
