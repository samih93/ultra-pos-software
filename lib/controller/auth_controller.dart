import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/repositories/auth_repository/authrepository.dart';
import 'package:desktoppossystem/repositories/auth_repository/iauthrepository.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/login/login_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = StateProvider<UserModel?>((ref) {
  return ref.watch(authControllerProvider).userModel;
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(
    ref: ref,
    authRepository: ref.read(authProviderRepository),
  );
});

class AuthController extends ChangeNotifier {
  final Ref _ref;
  final IAuthRepository _authRepository;
  AuthController({required Ref ref, required IAuthRepository authRepository})
    : _ref = ref,
      _authRepository = authRepository {
    _getCurrentUser();
  }
  UserModel? userModel;
  Future _getCurrentUser() async {
    try {
      userModel = await _ref.read(securePreferencesProvider).getUser();
      notifyListeners();
    } catch (e) {
      debugPrint("failed parsing $e");
    }
  }

  onSetUserModel(UserModel model) {
    userModel = model;
    notifyListeners();
  }

  RequestState signInRequestState = RequestState.success;
  String signInStatusMessage = "";
  Future signInWithEmailAndPassword(String email, String pass) async {
    signInRequestState = RequestState.loading;
    notifyListeners();
    final response = await _authRepository.signInWithEmailAndPassword(
      email,
      pass,
    );
    response.fold(
      (l) {
        signInRequestState = RequestState.error;
        signInStatusMessage = "email or password incorrect";
        notifyListeners();
      },
      (r) {
        userModel = r;

        signInRequestState = RequestState.success;
        signInStatusMessage = "Sign In Successfully";
        _ref
            .read(currentMainScreenProvider.notifier)
            .update((state) => ScreenName.SaleScreen);
        _ref.read(securePreferencesProvider).saveUser(r);
        notifyListeners();
      },
    );
  }

  bool showEmail = true;
  onchangeEmailVisibility() {
    showEmail = !showEmail;
    notifyListeners();
  }

  bool showPassword = true;
  onchangePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  RequestState signInWithPasswordRequestState = RequestState.success;

  Future signInWithPassword(String pass, BuildContext context) async {
    signInRequestState = RequestState.loading;
    notifyListeners();
    final signInRes = await _authRepository.signInWithCode(pass);
    signInRes.fold(
      (l) {
        signInRequestState = RequestState.error;
        notifyListeners();

        ToastUtils.showToast(message: l.message, type: RequestState.error);
        return null;
      },
      (r) {
        userModel = r;
        signInRequestState = RequestState.success;
        notifyListeners();
        _ref.read(securePreferencesProvider).saveUser(userModel!);
        ToastUtils.showToast(
          message: "Sign In Successfully",
          type: RequestState.success,
        );
        final isOwner =
            userModel!.id == int.tryParse(SecureConfig.quiverUserId);
        final onlyActivatedMenu = _ref
            .read(appPreferencesProvider)
            .getSecureBool(
              key: SecureConfig.onlyActivateMenuKey,
              defaultValue: false,
            );
        final menuActivated = _ref
            .read(appPreferencesProvider)
            .getBool(key: SecureConfig.activateMenuKey, defaultValue: false);

        if (globalAppContext.isMobile) {
          if (onlyActivatedMenu && menuActivated) {
            // Only menu mode - go to online menu
            globalAppWidgetRef
                .read(currentMainScreenProvider.notifier)
                .update((state) => ScreenName.OnlineMenuScreen);
          } else {
            // Regular mode - go to dashboard
            globalAppWidgetRef
                .read(currentMainScreenProvider.notifier)
                .update((state) => ScreenName.Dashboard);
          }
        } else {
          globalAppWidgetRef
              .read(currentMainScreenProvider.notifier)
              .update((state) => ScreenName.SaleScreen);
        }

        context.off(MainScreen());
      },
    );
  }

  RequestState logoutRequestState = RequestState.success;
  String logoutStatusMessage = "";

  Future<bool> logOut(BuildContext context) async {
    try {
      logoutRequestState = RequestState.loading;

      // 1. First navigate to login screen
      context.off(const LoginScreen());

      // 2. Then perform logout and cleanup
      final success = await _authRepository.logout();

      if (success) {
        await _ref.read(securePreferencesProvider).removeByKey(key: "user");
        await _ref.read(saleControllerProvider).resetSaleScreen();

        // 3. Proper provider cleanup with delay
        await Future.delayed(Duration.zero, () {
          invalidateProviders();
        });

        userModel = null;
      }

      logoutRequestState = success ? RequestState.success : RequestState.error;
      logoutStatusMessage = success
          ? "Logout successfully"
          : "Connection error";

      ToastUtils.showToast(
        type: logoutRequestState,
        message: logoutStatusMessage,
      );

      return success;
    } catch (error) {
      logoutRequestState = RequestState.error;
      logoutStatusMessage = error.toString();
      ToastUtils.showToast(
        type: logoutRequestState,
        message: logoutStatusMessage,
      );
      return false;
    }
  }

  invalidateProviders() {
    if (_ref.exists(stockControllerProvider)) {
      _ref.invalidate(stockControllerProvider);
    }
    if (_ref.exists(customerControllerProvider)) {
      _ref.invalidate(customerControllerProvider);
    }
    if (_ref.exists(dashboardControllerProvider)) {
      _ref.invalidate(dashboardControllerProvider);
    }
    if (_ref.exists(receiptControllerProvider)) {
      //! fix invalidate
      //_ref.refresh(receiptControllerProvider);
    }
    if (_ref.exists(profitControllerProvider)) {
      _ref.invalidate(profitControllerProvider);
    }
  }
}
