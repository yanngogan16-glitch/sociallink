import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/donation_model.dart';
import '../services/chat_service.dart';

class DonationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  String get _myUid => _auth.currentUser?.uid ?? '';

  // ✅ Faire un don — status pending jusqu'à confirmation ONG
  Future<void> makeDonation({
    required String programId,
    required String programTitle,
    required String ongId,
    required String ongName,
    required String donorName,
    required double amount,
    required String paymentMethod,
    required String message,
  }) async {
    // 1. Créer le don en status PENDING
    final donationRef = _db.collection('donations').doc();
    await donationRef.set(
      DonationModel(
        id: '',
        programId: programId,
        programTitle: programTitle,
        donorId: _myUid,
        donorName: donorName,
        ongId: ongId,
        amount: amount,
        status: 'pending', // ✅ En attente
        paymentMethod: paymentMethod,
        message: message,
        createdAt: DateTime.now(),
      ).toMap(),
    );

    // 2. Envoyer message automatique à l'ONG
    await _db.collection('notifications').add({
      'userId': ongId,
      'title': 'Don en attente de confirmation',
      'message':
          'Un don de ${amount.toStringAsFixed(0)} FCFA a ete realise pour '
          '"$programTitle". Contactez le service client SocialLink pour '
          'confirmer le paiement sur la plateforme avant validation.',
      'type': 'donation_pending',
      'donationId': donationRef.id,
      'programId': programId,
      'read': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    try {
      final chatId = await _chatService.getOrCreateChat(
        otherUid: ongId,
        otherName: ongName,
        myName: donorName,
      );

      final donorMessage = message.trim();
      final content = StringBuffer()
        ..write(
          "Bonjour ! Un don de ${amount.toStringAsFixed(0)} FCFA vient "
          "d'etre realise pour votre programme \"$programTitle\". "
          "Merci de contacter le service client SocialLink afin de confirmer "
          "le paiement sur la plateforme avant validation dans votre tableau ONG.",
        );

      if (donorMessage.isNotEmpty) {
        content.write("\n\nMessage du donateur : $donorMessage");
      }

      await _chatService.sendTextMessage(
        chatId: chatId,
        content: content.toString(),
        senderName: donorName,
        otherUid: ongId,
      );
    } catch (_) {
      // Le don reste en attente meme si le message automatique n'a pas pu etre envoye.
    }
  }

  Future<void> createDonation({
    required String programId,
    required double amount,
    required String paymentMethod,
    required String notes,
  }) async {
    throw UnsupportedError(
      'createDonation is deprecated. Use makeDonation with full program and ONG data.',
    );
  }

  // ✅ ONG confirme le don
  Future<void> confirmDonation(String donationId) async {
    final donRef = _db.collection('donations').doc(donationId);
    final don = await donRef.get();
    final data = don.data();
    if (data == null || data['status'] == 'confirmed') return;

    // Mettre à jour status
    await donRef.update({'status': 'confirmed'});

    // Mettre à jour montant du programme
    await _db.collection('programs').doc(data['programId']).update({
      'raisedAmount': FieldValue.increment((data['amount'] as num).toDouble()),
    });

    // Envoyer message de confirmation au donateur
    final myDoc = await _db.collection('users').doc(_myUid).get();
    final senderName = myDoc.data()?['name'] ?? 'SocialLink';
    final chatId = await _chatService.getOrCreateChat(
      otherUid: data['donorId'],
      otherName: data['donorName'] ?? 'Donateur',
      myName: senderName,
    );
    await _chatService.sendTextMessage(
      chatId: chatId,
      content:
          "Votre don de ${data['amount']} FCFA pour "
          "\"${data['programTitle']}\" a ete confirme. "
          "Merci pour votre genereux soutien !",
      senderName: senderName,
      otherUid: data['donorId'],
    );
  }

  // ✅ ONG rejette le don
  Future<void> rejectDonation(String donationId) async {
    final donRef = _db.collection('donations').doc(donationId);
    final don = await donRef.get();
    final data = don.data();
    if (data == null || data['status'] == 'rejected') return;

    await donRef.update({'status': 'rejected'});

    final myDoc = await _db.collection('users').doc(_myUid).get();
    final senderName = myDoc.data()?['name'] ?? 'SocialLink';
    final chatId = await _chatService.getOrCreateChat(
      otherUid: data['donorId'],
      otherName: data['donorName'] ?? 'Donateur',
      myName: senderName,
    );
    await _chatService.sendTextMessage(
      chatId: chatId,
      content:
          "Votre don de ${data['amount']} FCFA pour "
          "\"${data['programTitle']}\" n'a pas ete valide. "
          "Vous pouvez contacter l'ONG pour plus de details.",
      senderName: senderName,
      otherUid: data['donorId'],
    );
  }

  // ✅ Dons en attente pour une ONG
  Stream<List<DonationModel>> getPendingDonationsForOng(String ongId) {
    return _db
        .collection('donations')
        .where('ongId', isEqualTo: ongId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final donations = snap.docs
              .map((doc) => DonationModel.fromFirestore(doc))
              .toList();
          donations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return donations;
        });
  }

  // ✅ Historique dons confirmés du bailleur
  Stream<List<DonationModel>> getMyDonations() {
    return _db
        .collection('donations')
        .where('donorId', isEqualTo: _myUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => DonationModel.fromFirestore(doc)).toList(),
        );
  }

  // ✅ Total confirmé seulement
  Future<double> getMyTotalDonated() async {
    final snap = await _db
        .collection('donations')
        .where('donorId', isEqualTo: _myUid)
        .where('status', isEqualTo: 'confirmed')
        .get();
    return snap.docs.fold<double>(0, (totalAmount, doc) {
      final data = doc.data();
      return totalAmount + ((data['amount'] as num?)?.toDouble() ?? 0);
    });
  }
}
