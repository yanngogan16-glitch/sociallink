import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resource_person_model.dart';

class ResourcePersonService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ S'inscrire comme personne ressource
  Future<void> registerAsResourcePerson(ResourcePersonModel person) async {
    await _db.collection('resource_persons').add(person.toMap());
  }

  // ✅ Toutes les personnes ressources disponibles
  Stream<List<ResourcePersonModel>> getAvailablePersons({
    String? specialty,
  }) {
    Query query = _db
      .collection('resource_persons')
      .where('isAvailable', isEqualTo: true);

    if (specialty != null && specialty != 'Tous') {
      query = query.where('specialty', isEqualTo: specialty);
    }

    return query.snapshots().map((snap) => snap.docs
      .map((doc) => ResourcePersonModel.fromFirestore(doc))
      .toList());
  }

  // ✅ Profil d'une personne ressource
  Future<ResourcePersonModel?> getPersonProfile(String userId) async {
    final snap = await _db
      .collection('resource_persons')
      .where('userId', isEqualTo: userId)
      .limit(1)
      .get();
    if (snap.docs.isEmpty) return null;
    return ResourcePersonModel.fromFirestore(snap.docs.first);
  }

  // ✅ Mettre à jour disponibilité
  Future<void> updateAvailability(String docId, bool isAvailable) async {
    await _db.collection('resource_persons')
      .doc(docId)
      .update({'isAvailable': isAvailable});
  }
}