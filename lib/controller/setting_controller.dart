import 'dart:io';

import 'package:desktoppossystem/models/setting_model.dart';
import 'package:desktoppossystem/repositories/settings_repository/settings_repository.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/general_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:terminate_restart/terminate_restart.dart';

final settingControllerProvider = ChangeNotifierProvider<SettingController>((
  ref,
) {
  return SettingController(
    ref: ref,
    settingsRepository: ref.read(settingProviderRepository),
  );
});

class SettingController extends ChangeNotifier {
  final Ref _ref;
  final ISettingsRepository _settingsRepository;
  SettingController({
    required Ref ref,
    required ISettingsRepository settingsRepository,
  }) : _ref = ref,
       _settingsRepository = settingsRepository {
    fetchSettings();
  }

  var nameTextController = TextEditingController();
  var qrCodeTextController = TextEditingController();
  var locationTextController = TextEditingController();
  var phoneTextController = TextEditingController();
  var noteTextController = TextEditingController();
  SettingModel settingModel = SettingModel();
  Uint8List? photoBytes;
  bool printLogoOnInvoice = false;

  Future changePrintLogoStatus() async {
    printLogoOnInvoice = !printLogoOnInvoice;
    notifyListeners();
  }

  Future saveStoreInfo() async {
    settingModel = settingModel.copyWith(
      logo: photoBytes,
      storeName: nameTextController.text.trim(),
      storeLocation: locationTextController.text.trim(),
      storePhone: phoneTextController.text.trim(),
      storeQrCode: qrCodeTextController.text.trim(),
      note: noteTextController.text.trim(),
      printLogoOnInvoice: printLogoOnInvoice,
    );

    final response = await _settingsRepository.updateSettings(s: settingModel);
    response.fold(
      (l) {
        ToastUtils.showToast(
          message: "store info not saved",
          type: RequestState.success,
        );
      },
      (r) {
        ToastUtils.showToast(
          message: "store info saved successfully",
          type: RequestState.success,
        );
      },
    );
  }

  Future saveDolarRate(double dolarRate) async {
    settingModel = settingModel.copyWith(dolarRate: dolarRate);

    final response = await _settingsRepository.updateSettings(s: settingModel);
    response.fold(
      (l) {
        ToastUtils.showToast(
          message: "dolar rate not saved",
          type: RequestState.success,
        );
      },
      (r) {
        ToastUtils.showToast(
          message: "dolar rate saved successfully",
          type: RequestState.success,
        );
        _ref.read(saleControllerProvider).onchangeDolarRate(dolarRate);
      },
    );
  }

  Currency selectedSecondaryCurrency = Currency.LBP;
  Future onchangeSecondaryCurrency(Currency currency) async {
    selectedSecondaryCurrency = currency;
    notifyListeners();
  }

  Currency selectedPrimaryCurrency = Currency.USD;
  Future onchangePrimaryCurrency(Currency currency) async {
    selectedPrimaryCurrency = currency;
    notifyListeners();
  }

  // local => secondary
  // Primary = > primary
  Future saveCurrencies(BuildContext context) async {
    settingModel = settingModel.copyWith(
      primaryCurrency: selectedPrimaryCurrency,
      secondaryCurrency: selectedSecondaryCurrency,
    );

    final response = await _settingsRepository.updateSettings(s: settingModel);
    response.fold(
      (l) {
        ToastUtils.showToast(
          message: "Currencies not saved",
          type: RequestState.success,
        );
      },
      (r) {
        ToastUtils.showToast(
          message: "Currencies saved",
          type: RequestState.success,
        );
      },
    );
  }

  RequestState backupDatabaseRequestState = RequestState.success;
  String backupMessage = '';

  //MARK: backup to cloud

  Future<void> backupDatabaseToCloud() async {
    backupDatabaseRequestState = RequestState.loading;
    backupMessage = 'Authenticating...';
    notifyListeners();

    AuthResponse res = await signInSilently();
    backupMessage = 'Authenticated ✅, uploading...';
    notifyListeners();

    if (res.user != null) {
      // Locate the database file
      String? registrationUserId = await _ref
          .read(securePreferencesProvider)
          .getData(key: "registrationUserId");

      if (registrationUserId != null) {
        final response = await _ref
            .read(databaseBackupRestoreServiceProvider)
            .backupDatabaseToCloud(registrationUserId);
        response.fold(
          (l) {
            backupDatabaseRequestState = RequestState.error;
            notifyListeners();
            ToastUtils.showToast(message: l.message, type: RequestState.error);
          },
          (r) async {
            backupDatabaseRequestState = RequestState.success;
            notifyListeners();
            ToastUtils.showToast(
              message: 'backed up successfully, Data size $r',
              type: RequestState.success,
              duration: const Duration(seconds: 3),
            );
          },
        );
      }
    }
    await _ref.read(supaBaseProvider).auth.signOut();
  }
  //MARK: backup database

  RequestState localBackupRequestState = RequestState.success;
  Future backupDatabase() async {
    localBackupRequestState = RequestState.loading;
    notifyListeners();

    final response = await _ref
        .read(databaseBackupRestoreServiceProvider)
        .backupDatabase();
    response.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
        localBackupRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        ToastUtils.showToast(
          message: "Backup zip created successfully",
          type: RequestState.success,
        );
        localBackupRequestState = RequestState.error;
        notifyListeners();
      },
    );
  }

  //MARK: restore database

  Future<void> restoreDatabase() async {
    final response = await _ref
        .read(databaseBackupRestoreServiceProvider)
        .restoreDatabase();
    response.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
        localBackupRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        if (Platform.isWindows) {
          ToastUtils.showToast(
            message:
                "Database restored successfully. The app will restart in 2 seconds...",
            type: RequestState.success,
          );

          Future.delayed(const Duration(seconds: 2), () async {
            // Launch external restart script (handles single-instance restriction)
            final installDir = Directory.current.path;
            final exePath = Platform.resolvedExecutable;
            final batchLauncher = path.join(installDir, 'launch_restart.bat');
            final restartScript = path.join(installDir, 'restart_app.ps1');

            if (File(batchLauncher).existsSync() &&
                File(restartScript).existsSync()) {
              try {
                // Launch restart script in detached mode
                await Process.start(
                  batchLauncher,
                  [restartScript, exePath, installDir],
                  mode: ProcessStartMode.detached,
                  runInShell: false,
                  workingDirectory: installDir,
                );

                debugPrint('Restart script launched, exiting app...');
              } catch (e) {
                debugPrint('Failed to launch restart script: $e');
              }
            } else {
              debugPrint(
                'Restart scripts not found - app will exit without restart',
              );
            }

            // Exit current instance (restart script will wait and then relaunch)
            exit(0);
          });
        } else {
          ToastUtils.showToast(
            message: "Database restored successfully",
            type: RequestState.success,
          );
          TerminateRestart.instance.restartApp(
            options: const TerminateRestartOptions(terminate: true),
          );
        }
        localBackupRequestState = RequestState.error;
        notifyListeners();
      },
    );
  }

  XFile? pickedFile;

  Future pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['jpg', 'png', 'jpeg'],
        type: FileType.custom,
      );

      if (result != null) {
        // Load image into memory
        Uint8List imageBytes = await File(
          result.files.single.path!,
        ).readAsBytes();

        // Decode image
        img.Image? decodedImage = img.decodeImage(imageBytes);
        if (decodedImage == null) {
          throw Exception("Unable to decode image");
        }

        // Resize if necessary to 300px max
        if (decodedImage.width > 300 || decodedImage.height > 300) {
          decodedImage = img.copyResize(
            decodedImage,
            width: decodedImage.width > decodedImage.height ? 300 : null,
            height: decodedImage.height >= decodedImage.width ? 300 : null,
          );
        }

        // Encode back to bytes (JPEG with quality compression)
        Uint8List resizedBytes = Uint8List.fromList(
          img.encodeJpg(decodedImage, quality: 80),
        );

        // Save compressed bytes and file reference
        photoBytes = resizedBytes;
        pickedFile = result.files.single.xFile;
      } else {
        ToastUtils.showToast(
          message: "No image selected",
          type: RequestState.error,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
    }

    notifyListeners();
  }

  //MARK: fetch setting
  RequestState fetchSettingRequestState = RequestState.success;
  Future fetchSettings() async {
    await Future.delayed(const Duration(milliseconds: 100)).then((value) {
      final showDeliver = _ref
          .read(appPreferencesProvider)
          .getBool(key: "showDeliverPackage");

      showQuickSelectionProducts = _ref
          .read(appPreferencesProvider)
          .getBool(key: "showQuickSelectionProducts");
      _ref.read(showDeliverPackageProvider.notifier).state = showDeliver;

      final allowNegative = _ref
          .read(appPreferencesProvider)
          .getBool(key: "allowNegativeDiscount");
      _ref.read(allowNegativeDiscountProvider.notifier).state = allowNegative;
      final showTable = _ref
          .read(appPreferencesProvider)
          .getBool(key: "showTablesProvider");

      _ref.read(showTablesProvider.notifier).state = showTable;
      final fullScreen = _ref
          .read(appPreferencesProvider)
          .getBool(key: "isFullScreen");

      _ref.read(isFullScreenStateProvider.notifier).state = fullScreen;
    });
    fetchSettingRequestState = RequestState.loading;
    notifyListeners();

    final response = await _settingsRepository.fetchSettings();
    response.fold(
      (l) {
        fetchSettingRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        settingModel = r;
        photoBytes = settingModel.logo;
        nameTextController.text = settingModel.storeName.validateString();
        locationTextController.text = settingModel.storeLocation
            .validateString();
        phoneTextController.text = settingModel.storePhone.validateString();
        qrCodeTextController.text = settingModel.storeQrCode.validateString();
        noteTextController.text = settingModel.note.validateString();
        selectedSecondaryCurrency = settingModel.secondaryCurrency!;
        selectedPrimaryCurrency = settingModel.primaryCurrency!;

        AppConstance.secondaryCurrency = selectedSecondaryCurrency.name;
        AppConstance.primaryCurrency = selectedPrimaryCurrency.name;
        printLogoOnInvoice = settingModel.printLogoOnInvoice!;
        _ref.read(saleControllerProvider).onchangeDolarRate(r.dolarRate ?? 0);
        fetchSettingRequestState = RequestState.success;
        notifyListeners();
      },
    );
  }

  //MARK: add setting
  RequestState addSettingRequestState = RequestState.success;
  Future addSettings(SettingModel settingModel) async {
    addSettingRequestState = RequestState.loading;
    notifyListeners();

    final response = await _settingsRepository.addSettings(settingModel);
    response.fold(
      (l) {
        addSettingRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        settingModel = r;
        addSettingRequestState = RequestState.success;
        notifyListeners();
      },
    );
  }

  //MARK: update setting
  RequestState updateSettingRequestState = RequestState.success;
  Future updateSettings(SettingModel settingModel) async {
    updateSettingRequestState = RequestState.loading;
    notifyListeners();

    final response = await _settingsRepository.updateSettings(s: settingModel);
    response.fold(
      (l) {
        updateSettingRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        settingModel = r;
        updateSettingRequestState = RequestState.success;
        notifyListeners();
      },
    );
  }

  bool showQuickSelectionProducts = false;
  onChangeQuickSelectionProducts() {
    showQuickSelectionProducts = !showQuickSelectionProducts;
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: "showQuickSelectionProducts",
          value: showQuickSelectionProducts,
        );
    notifyListeners();
  }
}
