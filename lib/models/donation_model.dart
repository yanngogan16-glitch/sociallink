import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String programId;
  final String programTitle;
  final String donorId;
  final String donorName;
  final String ongId; // ✅ ajouté
  final double amount;
  final String status; // 'pending' | 'confirmed' | 'rejected'
  final String paymentMethod;
  final String message;
  final DateTime createdAt;

  DonationModel({
    required this.id,
    required this.programId,
    required this.programTitle,
    required this.donorId,
    required this.donorName,
    required this.ongId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.message,
    required this.createdAt,
  });

  factory DonationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DonationModel(
      id: doc.id,
      programId: d['programId'] ?? '',
      programTitle: d['programTitle'] ?? '',
      donorId: d['donorId'] ?? '',
      donorName: d['donorName'] ?? '',
      ongId: d['ongId'] ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      status: d['status'] ?? 'pending',
      paymentMethod: d['paymentMethod'] ?? '',
      message: d['message'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate()
        ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'programId': programId,
    'programTitle': programTitle,
    'donorId': donorId,
    'donorName': donorName,
    'ongId': ongId,
    'amount': amount,
    'status': status,
    'paymentMethod': paymentMethod,
    'message': message,
    'createdAt': FieldValue.serverTimestamp(),
  };

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
}