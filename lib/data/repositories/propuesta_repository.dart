import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviexpress_app/data/models/propuesta_model.dart';
import 'package:uuid/uuid.dart';

class PropuestaRepository {
  static final instance = PropuestaRepository._();
  PropuestaRepository._();

  final CollectionReference _proposalCollection = FirebaseFirestore.instance
      .collection('proposal');

  Future<void> createPropuesta(PropuestaModel propuesta) async {
    try {
      final query =
          await _proposalCollection
              .where('serviceId', isEqualTo: propuesta.serviceId)
              .where('workerId', isEqualTo: propuesta.workerId)
              .where('clientId', isEqualTo: propuesta.clientId)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final existingDocId = query.docs.first.id;

        await _proposalCollection.doc(existingDocId).update(propuesta.toJson());
      } else {
        await _proposalCollection.doc(propuesta.id).set(propuesta.toJson());
      }
    } catch (e) {
      throw Exception('Error al guardar propuesta: $e');
    }
  }

  Stream<Set<PropuestaModel>> getAllPropuestasForService(String? serviceId) {
    if (serviceId == null || serviceId.isEmpty) {
      return const Stream.empty();
    }

    try {
      return _proposalCollection
          .where('serviceId', isEqualTo: serviceId)
          .snapshots()
          .map((querySnapshot) {
            return querySnapshot.docs
                .map(
                  (doc) => PropuestaModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .where(
                  (propuesta) =>
                      propuesta.serviceId.isNotEmpty &&
                      propuesta.workerId.isNotEmpty &&
                      propuesta.clientId.isNotEmpty,
                )
                .toSet();
          });
    } catch (e) {
      return const Stream.empty();
    }
  }

  String generatePropuestaId() {
    return const Uuid().v4();
  }
}
