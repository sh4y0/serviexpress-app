import 'package:dart_either/dart_either.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class UseCaseWithoutParams<Type> {
  Future<Either<Failure, Type>> call();
}

abstract class UseCaseWithParams<Params> {
  Future<Either<Failure, void>> call(Params params);
}