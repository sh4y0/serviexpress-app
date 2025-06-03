import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/repositories/service_repository.dart';

class ServiceCompleteViewModel
    extends StateNotifier<ResultState<ServiceComplete>> {
  ServiceCompleteViewModel() : super(const Idle());

  /*Future<void> getService(String servicioId) async {
    state = const Loading();

    try {
      final result = await ServiceRepository.instance.getService(servicioId);

      if (result is Success<ServiceComplete>) {
        state = Success(result.data);
      } else if (result is Failure) {
        state = Failure(ErrorMapper.map(result.error));
      }
    } catch (e) {
      state = Failure(
        UnknownError("Error al obtener el servicio: ${e.toString()}"),
      );
    }
  }*/
}

final serviceCompleteViewModelProvider = StateNotifierProvider<
  ServiceCompleteViewModel,
  ResultState<ServiceComplete>
>((ref) => ServiceCompleteViewModel());
