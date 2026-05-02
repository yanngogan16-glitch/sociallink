import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final String type; // 'text' | 'image' | 'file'
  final String? fileUrl;
  final String? fileName;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    this.fileUrl,
    this.fileName,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: d['senderId'] ?? '',
      senderName: d['senderName'] ?? '',
      content: d['content'] ?? '',
      type: d['type'] ?? 'text',
      fileUrl: d['fileUrl'],
      fileName: d['fileName'],
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate()
        ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'senderName': senderName,
    'content': content,
    'type': type,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'isRead': isRead,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCounts;
  final Map<String, String> participantNames;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    this.lastMessageTime,
    required this.unreadCounts,
    required this.participantNames,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(d['participants'] ?? []),
      lastMessage: d['lastMessage'] ?? '',
      lastMessageTime:
        (d['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCounts: Map<String, int>.from(d['unreadCounts'] ?? {}),
      participantNames:
        Map<String, String>.from(d['participantNames'] ?? {}),
    );
  }

  int unreadFor(String uid) => unreadCounts[uid] ?? 0;

  String otherParticipantName(String myUid) {
    final otherId = participants.firstWhere(
      (id) => id != myUid, orElse: () => '');
    return participantNames[otherId] ?? 'Utilisateur';
  }
}