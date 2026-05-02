import 'package:cloud_firestore/cloud_firestore.dart';

class ResourcePersonModel {
  final String id;
  final String userId;
  final String name;
  final String specialty;
  final String otherSpecialty;
  final String bio;
  final String location;
  final String interventionMode; // 'presentiel' | 'enligne' | 'les deux'
  final String compensationType; // 'benevole' | 'compense' | 'les deux'
  final double? compensationAmount;
  final String availability;
  final String phone;
  final String email;
  final bool isAvailable;
  final DateTime createdAt;

  ResourcePersonModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.specialty,
    this.otherSpecialty = '',
    required this.bio,
    required this.location,
    required this.interventionMode,
    required this.compensationType,
    this.compensationAmount,
    required this.availability,
    required this.phone,
    required this.email,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory ResourcePersonModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ResourcePersonModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      name: d['name'] ?? '',
      specialty: d['specialty'] ?? '',
      otherSpecialty: d['otherSpecialty'] ?? '',
      bio: d['bio'] ?? '',
      location: d['location'] ?? '',
      interventionMode: d['interventionMode'] ?? 'les deux',
      compensationType: d['compensationType'] ?? 'les deux',
      compensationAmount: (d['compensationAmount'] as num?)?.toDouble(),
      availability: d['availability'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      isAvailable: d['isAvailable'] ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'specialty': specialty,
    'otherSpecialty': otherSpecialty,
    'bio': bio,
    'location': location,
    'interventionMode': interventionMode,
    'compensationType': compensationType,
    'compensationAmount': compensationAmount,
    'availability': availability,
    'phone': phone,
    'email': email,
    'isAvailable': isAvailable,
    'createdAt': FieldValue.serverTimestamp(),
  };
}