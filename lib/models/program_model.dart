import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String ongId;
  final String ongName;
  final double targetAmount;
  final double raisedAmount;
  final int spotsTotal;
  final int spotsTaken;
  final String status;
  final DateTime createdAt;
  final double? latitude;  // ✅ ajouté
  final double? longitude; // ✅ ajouté

  ProgramModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.ongId,
    required this.ongName,
    required this.targetAmount,
    required this.raisedAmount,
    required this.spotsTotal,
    required this.spotsTaken,
    required this.status,
    required this.createdAt,
    this.latitude,  // ✅
    this.longitude, // ✅
  });

  factory ProgramModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      ongId: data['ongId'] ?? '',
      ongName: data['ongName'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      raisedAmount: (data['raisedAmount'] ?? 0).toDouble(),
      spotsTotal: data['spotsTotal'] ?? 0,
      spotsTaken: data['spotsTaken'] ?? 0,
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate()
        ?? DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble(),   // ✅
      longitude: (data['longitude'] as num?)?.toDouble(), // ✅
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'location': location,
    'ongId': ongId,
    'ongName': ongName,
    'targetAmount': targetAmount,
    'raisedAmount': raisedAmount,
    'spotsTotal': spotsTotal,
    'spotsTaken': spotsTaken,
    'status': status,
    'createdAt': FieldValue.serverTimestamp(),
    'latitude': latitude,   // ✅
    'longitude': longitude, // ✅
  };

  double get donationProgress => targetAmount > 0
    ? (raisedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  int get spotsLeft => spotsTotal - spotsTaken;
}