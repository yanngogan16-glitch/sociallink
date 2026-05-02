import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class AdminResourcesScreen extends StatelessWidget {
  const AdminResourcesScreen({super.key});

  Future<void> _delete(BuildContext context, String id) async {
    await FirebaseFirestore.instance
      .collection('resource_persons').doc(id).delete();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil supprime"),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _validate(BuildContext context, String id) async {
    await FirebaseFirestore.instance
      .collection('resource_persons')
      .doc(id)
      .update({'validated': true});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil valide"),
          backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("PERSONNES RESSOURCES"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('resource_persons')
          .orderBy('createdAt', descending: true)
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: AppTheme.gold));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text("Aucune personne ressource",
                style: TextStyle(color: AppTheme.textLight)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;
              final validated = data['validated'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: validated
                      ? Colors.green.withValues(alpha: 0.3)
                      : AppTheme.gold.withValues(alpha: 0.15)),
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (data['name'] ?? '?').toString().isNotEmpty
                          ? data['name'].toString()[0].toUpperCase()
                          : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bgDark,
                        )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                          )),
                        Text(data['specialty'] ?? '',
                          style: const TextStyle(
                            fontSize: 12, color: AppTheme.gold)),
                        Text(data['location'] ?? '',
                          style: const TextStyle(
                            fontSize: 11, color: AppTheme.textLight)),
                      ],
                    ),
                  ),
                  Column(children: [
                    if (!validated)
                      GestureDetector(
                        onTap: () => _validate(context, id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.4)),
                          ),
                          child: const Text("Valider",
                            style: TextStyle(
                              fontSize: 11, color: Colors.green,
                              fontWeight: FontWeight.bold)),
                        ),
                      ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _delete(context, id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.4)),
                        ),
                        child: const Text("Supprimer",
                          style: TextStyle(
                            fontSize: 11, color: Colors.red,
                            fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}