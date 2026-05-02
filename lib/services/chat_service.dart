import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _myUid => _auth.currentUser?.uid ?? '';

  // ✅ Générer ID de chat unique
  String getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // ✅ Créer ou récupérer un chat
  Future<String> getOrCreateChat({
    required String otherUid,
    required String otherName,
    required String myName,
  }) async {
    final chatId = getChatId(_myUid, otherUid);
    final chatRef = _db.collection('chats').doc(chatId);
    final doc = await chatRef.get();

    if (!doc.exists) {
      await chatRef.set({
        'participants': [_myUid, otherUid],
        'participantNames': {_myUid: myName, otherUid: otherName},
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCounts': {_myUid: 0, otherUid: 0},
      });
    }
    return chatId;
  }

  // ✅ Envoyer message texte
  Future<void> sendTextMessage({
    required String chatId,
    required String content,
    required String senderName,
    required String otherUid,
  }) async {
    final batch = _db.batch();
    final msgRef = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    batch.set(
      msgRef,
      MessageModel(
        id: '',
        senderId: _myUid,
        senderName: senderName,
        content: content,
        type: 'text',
        isRead: false,
        createdAt: DateTime.now(),
      ).toMap(),
    );

    batch.update(_db.collection('chats').doc(chatId), {
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts.$otherUid': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ✅ Envoyer image
  Future<void> sendImageMessage({
    required String chatId,
    required File imageFile,
    required String senderName,
    required String otherUid,
  }) async {
    final ref = _storage.ref().child(
      'chats/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

    final batch = _db.batch();
    final msgRef = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    batch.set(
      msgRef,
      MessageModel(
        id: '',
        senderId: _myUid,
        senderName: senderName,
        content: ' Image',
        type: 'image',
        fileUrl: url,
        isRead: false,
        createdAt: DateTime.now(),
      ).toMap(),
    );

    batch.update(_db.collection('chats').doc(chatId), {
      'lastMessage': ' Image',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts.$otherUid': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ✅ Envoyer fichier
  Future<void> sendFileMessage({
    required String chatId,
    required File file,
    required String fileName,
    required String senderName,
    required String otherUid,
  }) async {
    final ref = _storage.ref().child(
      'chats/$chatId/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final batch = _db.batch();
    final msgRef = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    batch.set(
      msgRef,
      MessageModel(
        id: '',
        senderId: _myUid,
        senderName: senderName,
        content: ' $fileName',
        type: 'file',
        fileUrl: url,
        fileName: fileName,
        isRead: false,
        createdAt: DateTime.now(),
      ).toMap(),
    );

    batch.update(_db.collection('chats').doc(chatId), {
      'lastMessage': ' $fileName',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts.$otherUid': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ✅ Stream messages
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => MessageModel.fromFirestore(doc)).toList(),
        );
  }

  // Dernier message reel d'une conversation.
  Stream<MessageModel?> getLatestMessage(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return MessageModel.fromFirestore(snap.docs.first);
        });
  }

  // ✅ Stream liste des chats
  Stream<List<ChatModel>> getMyChats() {
    return _db
        .collection('chats')
        .where('participants', arrayContains: _myUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ChatModel.fromFirestore(doc)).toList(),
        );
  }

  // ✅ Marquer messages comme lus
  Future<void> markAsRead(String chatId) async {
    await _db.collection('chats').doc(chatId).update({
      'unreadCounts.$_myUid': 0,
    });
  }

  // ✅ Total messages non lus
  Stream<int> getTotalUnread() {
    return _db
        .collection('chats')
        .where('participants', arrayContains: _myUid)
        .snapshots()
        .map(
          (snap) => snap.docs.fold<int>(0, (total, doc) {
            final data = doc.data();
            final counts = Map<String, dynamic>.from(
              data['unreadCounts'] ?? {},
            );
            return total + ((counts[_myUid] as int?) ?? 0);
          }),
        );
  }
}
