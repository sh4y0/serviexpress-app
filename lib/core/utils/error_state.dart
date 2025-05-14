sealed class ErrorState {
  final String message;
  const ErrorState(this.message);
}

class NetworkError extends ErrorState {
  const NetworkError(super.message);
}

class InvalidCredentials extends ErrorState {
  const InvalidCredentials(super.message);
}

class UserNotFound extends ErrorState {
  const UserNotFound(super.message);
}

class EmailAlreadyInUse extends ErrorState {
  const EmailAlreadyInUse(super.message);
}

class TooManyRequest extends ErrorState {
  const TooManyRequest(super.message);
}

class ServiceUnavailable extends ErrorState {
  const ServiceUnavailable(super.message);
}

class Unauthorized extends ErrorState {
  const Unauthorized(super.message);
}

class UnknownError extends ErrorState {
  const UnknownError(super.message);
}

class CustomError extends ErrorState {
  const CustomError(super.message);
}
