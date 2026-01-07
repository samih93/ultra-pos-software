import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/role_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/repositories/auth_repository/iauthrepository.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../shared/constances/table_constant.dart';

final authProviderRepository = Provider((ref) {
  return AuthRepository(ref);
});

class AuthRepository implements IAuthRepository {
  final Ref ref;
  AuthRepository(this.ref);
  @override
  FutureEither<UserModel> signInWithEmailAndPassword(
      String email, String pass) async {
    try {
      UserModel? userModel;

      if (email == SecureConfig.coreEmail &&
          pass == SecureConfig.corePassword) {
        return right(UserModel(
            id: int.tryParse(SecureConfig.quiverUserId),
            name: 'Core Manager',
            password: '',
            email: 'coremanager@gmail.com',
            role: RoleModel(id: 12923, name: AuthRole.ownerRole)));
      }
      final checkResponse = await ref.read(posDbProvider).database.query(
          TableConstant.userTable,
          where: "email='${email.trim()}' and password='${pass.trim()}'");

      if (checkResponse.isNotEmpty) {
        final loginResponse = await ref.read(posDbProvider).database.rawQuery(
            'select u.id , u.email,u.name,r.role ,r.id as roleId from ${TableConstant.userTable} as u join ${TableConstant.roleTable} as r on u.roleId=r.id where u.id=${checkResponse[0]['id']}');
        userModel = UserModel.fromJson(loginResponse[0]);

        return right(userModel);
      } else {
        return left(FailureModel("invalid email or password"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<bool> logout() async {
    bool islogoutsuccessfully = true;
    // await usersReference
    //     .document(userId)
    //     .update({"isloggedIn": false}).then((value) {
    //   islogoutsuccessfully = true;
    //  debugPrint("updated login status");
    // }).catchError((error) {
    //   islogoutsuccessfully = false;
    //   Exception(error.toString());
    // });
    return islogoutsuccessfully;
  }

  @override
  FutureEither<UserModel?> signInWithCode(String pass) async {
    UserModel? userModel;
    try {
      var signInRes = await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.userTable, where: "password='$pass'");
      if (signInRes.isNotEmpty) {
        await ref
            .read(posDbProvider)
            .database
            .rawQuery(
                'select u.id , u.email,u.name,r.id as roleId , r.role from ${TableConstant.userTable} as u join ${TableConstant.roleTable} as r on u.roleId=r.id where u.id=${signInRes[0]['id']}')
            .then((value) {
          userModel = UserModel.fromJson(value[0]);
        });
        return right(userModel);
      } else {
        throw Exception("invalid Password");
      }
    } catch (e) {
      return Left(FailureModel(e.toString()));
    }
  }
}
