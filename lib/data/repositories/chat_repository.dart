import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/message_model.dart';

class ChatRepository {
  ChatRepository._privateConstructor();
  static final ChatRepository instance = ChatRepository._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ResultState<String>> sendMessage(MessageModel message) async {
    try {
      final chatId = _getChatId(message.senderId, message.receiverId);

      final chatDocRef = _firestore.collection('chat').doc(chatId);
      final messagesCollection = chatDocRef.collection("messages");

      final chatDocSnapshot = await chatDocRef.get();
      if (!chatDocSnapshot.exists) {
        await chatDocRef.set({}, SetOptions(merge: true));
      }

      final docRef =
          message.id == null
              ? messagesCollection.doc()
              : messagesCollection.doc(message.id);

      final messageToSave =
          message.id == null ? message.copyWith(id: docRef.id) : message;

      await docRef.set(messageToSave.toMap(useServerTimestamp: true));

      return const Success('Mensaje enviado');
    } on FirebaseException catch (e) {
      return Failure(ErrorMapper.map(e));
    } catch (e) {
      return const Failure(UnknownError("Ocurrió un error inesperado."));
    }
  }

  Stream<List<MessageModel>> getMessages(String uid1, String uid2) {
    final chatId = _getChatId(uid1, uid2);
    return _firestore
        .collection('chat')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          final messages =
              snapshot.docs
                  .map((doc) => MessageModel.fromMap(doc.data(), id: doc.id))
                  .toList();
          return messages;
        });
  }

  String _getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }
}
