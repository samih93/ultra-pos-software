import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/models/role_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/repositories/users/i_user_repository.dart';
import 'package:desktoppossystem/repositories/users/user_reposiotry.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userControllerProvider = ChangeNotifierProvider<UserController>((ref) {
  return UserController(
      ref: ref, userRepository: ref.read(userProviderRepository));
});

class UserController extends ChangeNotifier {
  final Ref _ref;
  final IUserRepository _userRepository;
  UserController({required Ref ref, required IUserRepository userRepository})
      : _ref = ref,
        _userRepository = userRepository {
    getAllUsers();
    fetchRoles();
  }

  List<RoleModel> roles = [];
  Future fetchRoles() async {
    roles = [];
    final response = await _userRepository.fetchRoles();
    response.fold(
      (l) {
        print("role message ${l.message}");
        roles = [];
      },
      (r) {
        roles = r;
        if (_ref.read(currentUserProvider)?.role?.name != AuthRole.ownerRole &&
            _ref.read(currentUserProvider)?.role?.name !=
                AuthRole.superAdminRole) {
          roles.removeWhere((e) => e.name == AuthRole.superAdminRole);
        }
      },
    );
    notifyListeners();
  }

  List<UserModel> users = [];
  List<UserModel> originalUser = [];

  RequestState getAllUsersRequestState = RequestState.success;
  Future<List<UserModel>> getAllUsers() async {
    getAllUsersRequestState = RequestState.loading;
    notifyListeners();
    await _userRepository.getAllUsers().then((value) {
      users = value;
      originalUser = users;

      getAllUsersRequestState = RequestState.success;
      notifyListeners();
    }).catchError((error) {
      getAllUsersRequestState = RequestState.error;
      notifyListeners();
    });
    return users;
  }

  //! start  add ,  update product in database
  RequestState addUpdateUserRequestState = RequestState.success;
  String addUpdateUserStatusMessage = "";

  Future updateUser(UserModel userModel, BuildContext context) async {
    addUpdateUserRequestState = RequestState.loading;
    notifyListeners();
    final updatedUserRes = await _userRepository.updateUser(userModel);
    updatedUserRes.fold((l) {
      addUpdateUserRequestState = RequestState.error;

      notifyListeners();
      ToastUtils.showToast(message: l.message, type: RequestState.error);
    }, (r) {
      for (var i = 0; i < users.length; i++) {
        if (users[i].id == userModel.id) {
          users[i] = r;
        }
      }

      addUpdateUserRequestState = RequestState.success;

// if current user update current user model
      if (_ref.read(currentUserProvider)?.id == userModel.id) {
        _ref.read(authControllerProvider.notifier).onSetUserModel(userModel);
      }
      notifyListeners();
      context.pop();

      ToastUtils.showToast(
          message: "User $successUpdatedStatusMessage",
          type: RequestState.success);
    });
  }

  Future addUser(UserModel userModel, BuildContext context) async {
    addUpdateUserRequestState = RequestState.loading;
    notifyListeners();
    final addUserRes = await _userRepository.addUser(userModel);
    addUserRes.fold((l) {
      addUpdateUserRequestState = RequestState.error;
      notifyListeners();
      ToastUtils.showToast(message: l.message, type: RequestState.error);
    }, (r) {
      users.add(r);
      addUpdateUserRequestState = RequestState.success;
      notifyListeners();
      ToastUtils.showToast(
          message: "User $successAddedStatusMessage",
          type: RequestState.success);
      context.pop();
    });
  }

  //! end  add ,  update product in database

  Future deleteUser(int id, BuildContext context) async {
    notifyListeners();
    await _userRepository.deleteUser(id).then((value) {
      if (value) {
        users.removeWhere((element) => element.id == id);
        ToastUtils.showToast(
            message: "User $successDeletedStatusMessage",
            type: RequestState.success);

        notifyListeners();
        context.pop();
      } else {
        ToastUtils.showToast(message: "Error!!!", type: RequestState.error);
        notifyListeners();
      }
    });
  }

  // ! search services by name
  filterUsersByName(String name) {
    if (name.trim() == "") {
      users = originalUser;
      notifyListeners();
    } else {
      users = originalUser
          .where((element) =>
              element.name!.toLowerCase().contains(name.toLowerCase()) ||
              element.email!.toLowerCase().contains(name.toLowerCase()))
          .toList();
      notifyListeners();
    }
  }

  clearSearch() {
    users = originalUser;
    notifyListeners();
  }
}
