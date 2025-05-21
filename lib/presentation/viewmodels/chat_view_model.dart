import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/message_model.dart';
import 'package:serviexpress_app/data/repositories/chat_repository.dart';

class ChatViewModel extends StateNotifier<ResultState> {
  ChatViewModel() : super(const Idle());

  Future<void> sendMessage(MessageModel message) async {
    state = const Loading();
    final result = await ChatRepository.instance.sendMessage(message);
    state = result;
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ResultState>(
  (ref) => ChatViewModel(),
);

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((
  ref,
  combinedUid,
) {
  final uids = combinedUid.split('_');
  final uid1 = uids[0];
  final uid2 = uids[1];
  return ChatRepository.instance.getMessages(uid1, uid2);
});
