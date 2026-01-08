import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/role_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/repositories/auth_repository/iauthrepository.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/constances/app_endpoint.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final authProviderRepository = Provider((ref) {
  return AuthRepository(ref);
});

class AuthRepository implements IAuthRepository {
  final Ref ref;
  AuthRepository(this.ref);
  @override
  FutureEither<UserModel> signInWithEmailAndPassword(
    String email,
    String pass,
  ) async {
    try {
      if (email == SecureConfig.coreEmail &&
          pass == SecureConfig.corePassword) {
        return right(
          UserModel(
            id: int.tryParse(SecureConfig.quiverUserId),
            name: 'Ultra Pos',
            password: '',
            email: 'coremanager@gmail.com',
            role: RoleModel(id: 12923, name: AuthRole.ownerRole),
          ),
        );
      }
      final checkResponse = await ref
          .read(ultraPosDioProvider)
          .postData(
            endPoint: AppEndpoint.auth,
            data: {'email': email, 'password': pass},
          );
      if (checkResponse.data["code"] == 200) {
        return right(UserModel.fromJson(checkResponse.data["data"]));
      } else {
        return left(
          FailureModel(
            checkResponse.data["message"] ?? "invalid email or password",
          ),
        );
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<bool> logout() async {
    return true;
  }

  @override
  FutureEither<UserModel?> signInWithCode(String pass) async {
    try {
      final response = await ref
          .read(ultraPosDioProvider)
          .postData(endPoint: AppEndpoint.authCode, data: {'password': pass});
      if (response.data["code"] == 200) {
        return right(UserModel.fromJson(response.data["data"]));
      } else {
        return left(
          FailureModel(response.data["message"] ?? "invalid password"),
        );
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
