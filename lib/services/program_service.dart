import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/program_model.dart';

class ProgramService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Créer un programme (ONG)
  Future<void> createProgram(ProgramModel program) async {
    await _db.collection('programs').add(program.toMap());
  }

  // ✅ Tous les programmes actifs (Donateur & Bénéficiaire)
  Stream<List<ProgramModel>> getActivePrograms() {
    return _db
      .collection('programs')
      .where('status', isEqualTo: 'active')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
        .map((doc) => ProgramModel.fromFirestore(doc))
        .toList());
  }

  // ✅ Programmes d'une ONG spécifique
  Stream<List<ProgramModel>> getOngPrograms(String ongId) {
    return _db
      .collection('programs')
      .where('ongId', isEqualTo: ongId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
        .map((doc) => ProgramModel.fromFirestore(doc))
        .toList());
  }

  // ✅ Inscrire un bénéficiaire
  Future<void> registerBeneficiary({
    required String programId,
    required String userId,
    required String userName,
  }) async {
    final batch = _db.batch();

    // Ajouter dans la sous-collection inscriptions
    final regRef = _db
      .collection('programs')
      .doc(programId)
      .collection('registrations')
      .doc(userId);

    batch.set(regRef, {
      'userId': userId,
      'userName': userName,
      'registeredAt': FieldValue.serverTimestamp(),
    });

    // Incrémenter spotsTaken
    final programRef = _db.collection('programs').doc(programId);
    batch.update(programRef, {
      'spotsTaken': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ✅ Vérifier si déjà inscrit
  Future<bool> isRegistered({
    required String programId,
    required String userId,
  }) async {
    final doc = await _db
      .collection('programs')
      .doc(programId)
      .collection('registrations')
      .doc(userId)
      .get();
    return doc.exists;
  }

  // ✅ Supprimer un programme (ONG)
  Future<void> deleteProgram(String programId) async {
    await _db.collection('programs').doc(programId).update({
      'status': 'deleted',
    });
  }
}