import 'package:desktoppossystem/models/failure_model.dart';
import 'package:fpdart/fpdart.dart';

typedef FutureEither<T> = Future<Either<FailureModel, T>>;
// return failure on fail and nothing on success
typedef FutureEitherVoid = FutureEither<void>;
