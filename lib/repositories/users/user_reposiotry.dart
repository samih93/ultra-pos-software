import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/role_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/repositories/users/i_user_repository.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../shared/constances/table_constant.dart';

final userProviderRepository = Provider((ref) {
  return UserRepository(ref);
});

class UserRepository extends IUserRepository {
  final Ref ref;
  UserRepository(this.ref);
  @override
  FutureEither<UserModel> addUser(UserModel userModel) async {
    try {
      final passwordCheck =
          await checkPasswordNotTaken(userModel.password.toString());
      UserModel user = UserModel.fakeUser();

      await passwordCheck.fold((l) {
        throw Exception(l.message);
      }, (r) async {
        // ! password not taken

        final insertedId = await ref
            .read(posDbProvider)
            .database
            .insert(TableConstant.userTable, userModel.toJsonWithoutId());
        user = userModel;
        user = user.copyWith(id: insertedId);
      });

      return right(user);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<bool> deleteUser(int id) async {
    bool isDeleted = false;
    await ref
        .read(posDbProvider)
        .database
        .delete(TableConstant.userTable, where: " id=$id")
        .then((value) {
      isDeleted = true;
    }).catchError((error) {
      isDeleted = false;
    });
    return isDeleted;
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    List<UserModel> users = [];
    await ref
        .read(posDbProvider)
        .database
        .rawQuery(
            'select u.id , u.email,u.name,u.password,u.roleId,r.role from ${TableConstant.userTable} as u join ${TableConstant.roleTable} as r on u.roleId=r.id ')
        .then((value) {
      users = List.from(value.map((e) => UserModel.fromJson(e)));
    });
    return users;
  }

  @override
  Future<UserModel> getUser(int id) {
    throw UnimplementedError();
  }

  @override
  FutureEither<UserModel> updateUser(UserModel userModel) async {
    try {
      final passwordCheck = await checkPasswordNotTaken(
          userModel.password.toString(),
          isForUpdate: true);
      UserModel user = UserModel.fakeUser();
      await passwordCheck.fold((l) {
        throw Exception(l.message);
      }, (r) async {
        // ! password not taken

        await ref
            .read(posDbProvider)
            .database
            .update(TableConstant.userTable, userModel.toJsonWithoutId(),
                where: " id=${userModel.id}")
            .then((value) {
          user = userModel;
        });
      });

      return right(user);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<bool> checkPasswordNotTaken(String pass,
      {bool? isForUpdate}) async {
    try {
      var res = await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.userTable, where: "password='$pass'");
      if (isForUpdate != null && res.length > 1) {
        return left(FailureModel("Password Already Taken"));
      }
      if (isForUpdate == null && res.isNotEmpty) {
        return left(FailureModel("Password Already Taken"));
      }
      return right(true);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<RoleModel>> fetchRoles() async {
    try {
      List<RoleModel> roles = [];
      await ref
          .read(posDbProvider)
          .database
          .rawQuery('select * from ${TableConstant.roleTable}')
          .then((value) {
        roles = List.from(value.map((e) => RoleModel.fromMap(e)));
      });
      return right(roles);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
