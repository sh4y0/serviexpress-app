import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/repositories/register_repository.dart';

class RegisterViewModel extends StateNotifier<ResultState> {
  RegisterViewModel() : super(const Idle());

  Future<void> registerUser(
    String email,
    String password,
    String username,
  ) async {
    state = const Loading();
    final result = await RegisterRepository.instance.registerUser(
      email,
      password,
      username,
    );

    state = result;
  }
}

final registerViewModelProvider =
    StateNotifierProvider<RegisterViewModel, ResultState>(
      (ref) => RegisterViewModel(),
    );
