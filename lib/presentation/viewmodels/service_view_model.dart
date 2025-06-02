import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/repositories/service_repository.dart';

class ServiceViewModel extends StateNotifier<ResultState<ServiceModel>> {
  ServiceViewModel() : super(const Idle());

  Future<void> createService({
    required ServiceModel service,
    List<File>? fotos,
    List<File>? videos,
  }) async {
    state = const Loading();

    try {
      final result = await ServiceRepository.instance.createService(
        service: service,
        fotos: fotos,
        videos: videos,
      );

      if (result is Success<ServiceModel>) {
        state = Success(result.data);
      } else if (result is Failure) {
        state = Failure(ErrorMapper.map(result.error));
      }
    } catch (e) {
      state = Failure(
        UnknownError("Error al crear el servicio: ${e.toString()}"),
      );
    }
  }

  String generateServiceId() {
    return ServiceRepository.instance.generateServiceId();
  }
}

final serviceViewModelProvider =
    StateNotifierProvider<ServiceViewModel, ResultState<ServiceModel>>(
      (ref) => ServiceViewModel(),
    );
