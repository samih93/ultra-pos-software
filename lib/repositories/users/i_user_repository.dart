import 'package:desktoppossystem/models/role_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';

abstract class IUserRepository {
  Future<List<UserModel>> getAllUsers();
  FutureEither<UserModel> addUser(UserModel userModel);
  FutureEither<UserModel> updateUser(UserModel userModel);
  Future<bool> deleteUser(int id);
  Future<UserModel> getUser(int id);
  FutureEither<bool> checkPasswordNotTaken(String pass, {bool? isForUpdate});
  FutureEither<List<RoleModel>> fetchRoles();
}
