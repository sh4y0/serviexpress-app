import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/fmc_message.dart';
import 'package:serviexpress_app/presentation/messaging/service/firebase_messaging_service.dart';

class NotificationViewModel extends StateNotifier<ResultState> {
  NotificationViewModel() : super(const Idle());

  Future<void> sendNotification(FCMMessage message, String userId) async {
    state = const Loading();

    final success = await FirebaseMessagingService.instance.sendFCMMessage(
      message,
      userId,
    );

    if (success) {
      state = const Success('Notificación enviada correctamente');
    } else {
      state = const Failure(UnknownError('Error al enviar la notificación'));
    }
  }
}

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, ResultState>(
      (ref) => NotificationViewModel(),
    );
