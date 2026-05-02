import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/chat_service.dart';
import '../chat/chats_list_screen.dart';
import '../chat/chat_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _db = FirebaseFirestore.instance;
  String _filterRole = 'Tous';

  final List<String> _roles = [
    'Tous',
    'ong',
    'donateur',
    'beneficiaire',
    'admin',
  ];

  Stream<QuerySnapshot> get _usersStream {
    if (_filterRole == 'Tous') {
      return _db
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return _db
        .collection('users')
        .where('role', isEqualTo: _filterRole)
        .snapshots();
  }

  // ignore: unused_element
  Future<void> _deleteUser(String uid) async {
    final confirm = await _showConfirmDialog(
      "Supprimer cet utilisateur ?",
      "Cette action est irreversible.",
    );
    if (!confirm) return;
    await _db.collection('users').doc(uid).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Utilisateur supprime"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ignore: unused_element
  Future<void> _suspendUser(String uid, bool suspended) async {
    await _db.collection('users').doc(uid).update({'suspended': !suspended});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            suspended ? "Utilisateur reactive" : "Utilisateur suspendu",
          ),
          backgroundColor: suspended ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.bgCard,
            title: Text(
              title,
              style: const TextStyle(color: AppTheme.textWhite),
            ),
            content: Text(
              message,
              style: const TextStyle(color: AppTheme.textLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Annuler",
                  style: TextStyle(color: AppTheme.textLight),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Confirmer",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("UTILISATEURS"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
        actions: [
          StreamBuilder<int>(
            stream: ChatService().getTotalUnread(),
            builder: (context, snapshot) {
              final unread = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppTheme.gold,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatsListScreen(),
                      ),
                    ),
                    tooltip: "Messagerie",
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre rôle
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _roles.length,
              itemBuilder: (_, i) {
                final role = _roles[i];
                final sel = role == _filterRole;
                return GestureDetector(
                  onTap: () => setState(() => _filterRole = role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: sel ? AppTheme.goldGradient : null,
                      color: sel ? null : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel
                            ? Colors.transparent
                            : AppTheme.gold.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        color: sel ? AppTheme.bgDark : AppTheme.textLight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Liste utilisateurs
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.gold),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun utilisateur",
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final uid = docs[i].id;
                    final suspended = data['suspended'] ?? false;
                    final role = data['role'] ?? 'inconnu';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: suspended
                            ? Colors.red.withValues(alpha: 0.05)
                            : AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: suspended
                              ? Colors.red.withValues(alpha: 0.3)
                              : AppTheme.gold.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (data['name'] ?? data['email'] ?? '?')
                                        .toString()
                                        .isNotEmpty
                                    ? (data['name'] ?? data['email'])
                                          .toString()[0]
                                          .toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.bgDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Sans nom',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textWhite,
                                  ),
                                ),
                                Text(
                                  data['email'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.gold.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        role,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.gold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (suspended) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          "Suspendu",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Bouton messagerie
                          IconButton(
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              color: AppTheme.gold,
                              size: 18,
                            ),
                            onPressed: () async {
                              final myDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .get();
                              final myName = myDoc.data()?['name'] ?? 'Admin';

                              final chatId = await ChatService()
                                  .getOrCreateChat(
                                    otherUid: uid,
                                    otherName: data['name'] ?? 'Utilisateur',
                                    myName: myName,
                                  );

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      chatId: chatId,
                                      otherUid: uid,
                                      otherName: data['name'] ?? 'Utilisateur',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
