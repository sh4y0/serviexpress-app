import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/repositories/auth_repository.dart';

class AuthViewModel extends StateNotifier<ResultState> {
  AuthViewModel() : super(const Idle());

  Future<void> loginUser(String email, String password) async {
    state = const Loading();
    final result = await AuthRepository.instance.loginUser(email, password);

    state = result;
  }

  Future<void> loginWithGoogle() async {
    state = const Loading();
    final result = await AuthRepository.instance.loginWithGoogle();
    state = result;
  }

  Future<void> loginWithFacebook() async {
    state = const Loading();
    final result = await AuthRepository.instance.loginWithFacebook();
    state = result;
  }

  Future<void> recoverPassword(String email) async {
    state = const Loading();
    final result = await AuthRepository.instance.recoverPassword(email);

    state = result;
  }

  void logout() {
    state = const Loading();
    final result = AuthRepository.instance.logout();

    state = result;
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, ResultState>(
  (ref) => AuthViewModel(),
);
