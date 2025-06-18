import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';

class DesactiveAccountViewModel extends StateNotifier<ResultState<String>> {
  DesactiveAccountViewModel() : super(const Idle());

  Future<void> deactivateCurrentUserAccount() async {
    state = const Loading();
    final result =
        await UserRepository.instance.desactivateCurrentUserAccount();
    state = result;
  }
}

final desactivateAccountViewModelProvider =
    StateNotifierProvider<DesactiveAccountViewModel, ResultState<String>>(
      (ref) => DesactiveAccountViewModel(),
    );
