import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';

abstract class IAuthRepository {
  FutureEither<UserModel> signInWithEmailAndPassword(String email, String pass);
  FutureEither<UserModel?> signInWithCode(String code);
  Future<bool> logout();
}
