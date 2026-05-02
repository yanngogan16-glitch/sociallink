import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class AdminProgramsScreen extends StatefulWidget {
  const AdminProgramsScreen({super.key});

  @override
  State<AdminProgramsScreen> createState() => _AdminProgramsScreenState();
}

class _AdminProgramsScreenState extends State<AdminProgramsScreen> {
  final _db = FirebaseFirestore.instance;
  String _filterStatus = 'Tous';

  final List<String> _statuses = [
    'Tous', 'active', 'pending', 'rejected', 'deleted'
  ];

  Stream<QuerySnapshot> get _programsStream {
    if (_filterStatus == 'Tous') {
      return _db.collection('programs')
        .orderBy('createdAt', descending: true)
        .snapshots();
    }
    return _db.collection('programs')
      .where('status', isEqualTo: _filterStatus)
      .snapshots();
  }

  Future<void> _updateStatus(String id, String status) async {
    await _db.collection('programs').doc(id).update({
      'status': status,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Programme : $status"),
          backgroundColor: status == 'active'
            ? Colors.green
            : status == 'rejected'
              ? Colors.orange : Colors.red,
        ));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'deleted': return Colors.grey;
      default: return AppTheme.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("PROGRAMMES"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
      ),
      body: Column(children: [

        // Filtres
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
            itemCount: _statuses.length,
            itemBuilder: (_, i) {
              final s = _statuses[i];
              final sel = s == _filterStatus;
              return GestureDetector(
                onTap: () => setState(() => _filterStatus = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: sel ? AppTheme.goldGradient : null,
                    color: sel ? null : AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                        ? Colors.transparent
                        : AppTheme.gold.withValues(alpha: 0.2)),
                  ),
                  child: Text(s,
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

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _programsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(
                  color: AppTheme.gold));
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text("Aucun programme",
                    style: TextStyle(color: AppTheme.textLight)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final id = docs[i].id;
                  final status = data['status'] ?? 'active';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _statusColor(status)
                          .withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(data['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textWhite,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(status)
                                  .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(status,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.bold,
                                )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text("${data['ongName']} • ${data['location']}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          )),
                        const SizedBox(height: 12),

                        // Boutons actions
                        Row(children: [
                          if (status != 'active')
                            _ActionBtn(
                              label: "Valider",
                              color: Colors.green,
                              onTap: () => _updateStatus(id, 'active'),
                            ),
                          if (status == 'active') ...[
                            _ActionBtn(
                              label: "Rejeter",
                              color: Colors.orange,
                              onTap: () => _updateStatus(id, 'rejected'),
                            ),
                          ],
                          const SizedBox(width: 8),
                          _ActionBtn(
                            label: "Supprimer",
                            color: Colors.red,
                            onTap: () => _updateStatus(id, 'deleted'),
                          ),
                        ]),
                      ],
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

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        )),
    ),
  );
}