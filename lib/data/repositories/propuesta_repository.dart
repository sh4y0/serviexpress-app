import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviexpress_app/data/models/propuesta_model.dart';

class PropuestaRepository {
  static final instance = PropuestaRepository._();
  PropuestaRepository._();

  final CollectionReference _proposalCollection = FirebaseFirestore.instance
      .collection('proposal');

  Future<void> createPropuesta(PropuestaModel propuesta) async {
    try {
      await _proposalCollection.doc(propuesta.id).set(propuesta.toJson());
    } catch (e) {
      throw Exception('Error creating propuesta: $e');
    }
  }

  Stream<Set<PropuestaModel>> getAllPropuestasForService(String? serviceId) {
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
}
