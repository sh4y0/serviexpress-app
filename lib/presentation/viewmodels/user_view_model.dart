import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';

class UserViewModel extends StateNotifier<ResultState<UserModel>> {
  UserViewModel() : super(const Idle());

  Future<void> getUserById(String uid) async {
    state = const Loading();
    final result = await UserRepository.instance.getUserById(uid);
    state = result;
  }

  Future<void> updateUserById(
    String uid,
    Map<String, dynamic> dataToUpdate,
  ) async {
    state = const Loading();
    final result = await UserRepository.instance.updateUserById(
      uid,
      dataToUpdate,
    );

    if (result is Success<String>) {
      await getUserById(uid);
    } else if (result is Failure) {
      state = Failure(ErrorMapper.map(result.error));
    }
  }

  Future<bool> isDniEmpty(String uid) async {
    return await UserRepository.instance.isDniEmpty(uid);
  }
}

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, ResultState<UserModel>>(
      (ref) => UserViewModel(),
    );
