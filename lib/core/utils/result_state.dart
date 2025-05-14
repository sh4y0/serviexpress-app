import 'package:serviexpress_app/core/utils/error_state.dart';

sealed class ResultState<T> {
  const ResultState();
}

class Idle<T> extends ResultState<T> {
  const Idle();
}

class Loading<T> extends ResultState<T> {
  const Loading();
}

class Success<T> extends ResultState<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends ResultState<T> {
  final ErrorState error;
  const Failure(this.error);
}

extension ResultStateX<T> on ResultState<T> {
  bool get isLoading => this is Loading<T>;
  T? get value => this is Success<T> ? (this as Success<T>).data : null;
  ErrorState? get error =>
      this is Failure<T> ? (this as Failure<T>).error : null;
}
