import 'package:desktoppossystem/models/user_licence_model.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';

abstract class ILicenseRepository {
  FutureEither<Map<String, String>> activateApp(String license);
  FutureEitherVoid disableLicense(String license);
  FutureEitherVoid saveActivationInfo(UserLicencesModel userLicencesModel);
}
