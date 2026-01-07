import 'dart:io';
import 'dart:ui';

import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/services/file_logger.dart';
import 'package:desktoppossystem/shared/services/pos_db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';

class AppConfiguration {
  static Future<void> prepareConfiguration(WidgetRef ref) async {
    try {
      await FileLogger().log('App configuration started');

      if (Platform.isWindows) {
        await FileLogger().log('Platform: Windows');
        await windowManager.ensureInitialized();
        // Configure window options
        WindowOptions windowOptions = WindowOptions(
          fullScreen: AppConstance.isFullScreen,
          minimumSize: AppConstance.isFullScreen ? null : const Size(1080, 700),
          center: true,
        );
        windowManager.waitUntilReadyToShow(windowOptions, () async {
          // Uncomment these if you want to show and focus the window immediately
          await windowManager.show();
          await windowManager.focus();
        });
        await FileLogger().log('Window manager initialized');
      }

      await FileLogger().log('Initializing database and localization...');
      await Future.wait([
        Platform.isWindows
            ? PosDbHelper.db.initWindows()
            : PosDbHelper.db.initMobile(),

        // Initialize date formatting
        initializeDateFormatting(),
      ]);

      await FileLogger().log('App configuration completed successfully');
    } catch (e, stackTrace) {
      await FileLogger().logError(
        'CRITICAL: App configuration failed',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
