import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _filterRole = 'Tous';
  final _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<String> _roles = [
    'Tous', 'ong', 'donateur', 'beneficiaire'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("NOUVELLE CONVERSATION"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
      ),
      body: Column(children: [

        // Barre recherche
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: AppTheme.textWhite),
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: "Rechercher un utilisateur...",
              hintStyle: TextStyle(
                color: AppTheme.textLight.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.search,
                color: AppTheme.gold, size: 20),
              filled: true,
              fillColor: AppTheme.bgSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppTheme.gold, width: 1.5),
              ),
            ),
          ),
        ),

        // Filtre rôle
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: sel ? AppTheme.goldGradient : null,
                    color: sel ? null : AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                        ? Colors.transparent
                        : AppTheme.gold.withValues(alpha: 0.2)),
                  ),
                  child: Text(role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: sel
                        ? FontWeight.bold : FontWeight.normal,
                      color: sel
                        ? AppTheme.bgDark : AppTheme.textLight,
                    )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Liste utilisateurs
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _filterRole == 'Tous'
              ? FirebaseFirestore.instance
                  .collection('users')
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: _filterRole)
                  .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.gold));
              }

              var docs = snapshot.data?.docs ?? [];

              // Exclure l'utilisateur actuel
              docs = docs.where((d) => d.id != _myUid).toList();

              // Filtre recherche
              if (_search.isNotEmpty) {
                docs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '')
                    .toString().toLowerCase();
                  final email = (data['email'] ?? '')
                    .toString().toLowerCase();
                  return name.contains(_search.toLowerCase()) ||
                    email.contains(_search.toLowerCase());
                }).toList();
              }

              if (docs.isEmpty) {
                return const Center(
                  child: Text("Aucun utilisateur trouvé",
                    style: TextStyle(color: AppTheme.textLight)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final data =
                    docs[i].data() as Map<String, dynamic>;
                  final uid = docs[i].id;
                  final name = data['name'] ?? 'Sans nom';
                  final role = data['role'] ?? '';
                  final email = data['email'] ?? '';

                  return GestureDetector(
                    onTap: () async {
                      final myDoc = await FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(_myUid)
                        .get();
                      final myName =
                        myDoc.data()?['name'] ?? 'Moi';

                      final chatId = await ChatService()
                        .getOrCreateChat(
                          otherUid: uid,
                          otherName: name,
                          myName: myName,
                        );

                      if (context.mounted) {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                            ChatScreen(
                              chatId: chatId,
                              otherUid: uid,
                              otherName: name,
                            )));
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.gold.withValues(
                            alpha: 0.15)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty
                                ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.bgDark,
                              )),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                              CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textWhite,
                                )),
                              const SizedBox(height: 4),
                              Row(children: [
                                Container(
                                  padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gold
                                      .withValues(alpha: 0.15),
                                    borderRadius:
                                      BorderRadius.circular(10),
                                  ),
                                  child: Text(role,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.gold,
                                      fontWeight: FontWeight.bold,
                                    )),
                                ),
                                const SizedBox(width: 8),
                                Text(email,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textLight,
                                  )),
                              ]),
                            ],
                          ),
                        ),
                        const Icon(Icons.chat_bubble_outline,
                          color: AppTheme.gold, size: 18),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}