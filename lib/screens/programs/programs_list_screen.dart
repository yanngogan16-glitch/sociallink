import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program_model.dart';
import '../../services/program_service.dart';
import '../../theme/app_theme.dart';
import 'program_detail_screen.dart';
import '../../widgets/trust_badge.dart';
import '../../models/trust_level.dart';

class ProgramsListScreen extends StatefulWidget {
  final String viewerRole; // 'donateur' ou 'beneficiaire'
  const ProgramsListScreen({super.key, required this.viewerRole});

  @override
  State<ProgramsListScreen> createState() => _ProgramsListScreenState();
}

class _ProgramsListScreenState extends State<ProgramsListScreen> {
  final ProgramService _service = ProgramService();
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Alimentation',
    'Éducation',
    'Santé',
    'Eau potable',
    'Formation',
    'Logement',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("Programmes"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
      ),
      body: Column(
        children: [
          // Filtre catégories
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected ? AppTheme.goldGradient : null,
                      color: selected ? null : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : AppTheme.gold.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected ? AppTheme.bgDark : AppTheme.textLight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Liste programmes
          Expanded(
            child: StreamBuilder<List<ProgramModel>>(
              stream: _service.getActivePrograms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.gold),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erreur : ${snapshot.error}",
                      style: const TextStyle(color: AppTheme.textLight),
                    ),
                  );
                }

                var programs = snapshot.data ?? [];

                // Filtre catégorie
                if (_selectedCategory != 'Tous') {
                  programs = programs
                      .where((p) => p.category == _selectedCategory)
                      .toList();
                }

                if (programs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "",
                          style: TextStyle(fontSize: 40, color: AppTheme.gold),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Aucun programme disponible",
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: programs.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ProgramCard(
                      program: programs[i],
                      viewerRole: widget.viewerRole,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProgramDetailScreen(
                            program: programs[i],
                            viewerRole: widget.viewerRole,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final ProgramModel program;
  final String viewerRole;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.program,
    required this.viewerRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Catégorie + ONG
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  program.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bgDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _OngTrustRow(program: program),
            ],
          ),
          const SizedBox(height: 12),

          // Titre
          Text(
            program.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 6),

          // Localisation
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppTheme.gold,
              ),
              const SizedBox(width: 4),
              Text(
                program.location,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Barre de progression don
          if (program.targetAmount > 0) ...[
            LinearProgressIndicator(
              value: program.donationProgress,
              color: AppTheme.gold,
              backgroundColor: AppTheme.gold.withValues(alpha: 0.1),
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${program.raisedAmount.toStringAsFixed(0)} FCFA",
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "/ ${program.targetAmount.toStringAsFixed(0)} FCFA",
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Places & bouton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 14,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${program.spotsLeft} places",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  viewerRole == 'donateur' ? "Faire un don" : "Voir plus",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bgDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _OngTrustRow extends StatelessWidget {
  final ProgramModel program;

  const _OngTrustRow({required this.program});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: Text(
          program.ongName,
          style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 8),
      FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(program.ongId)
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) return const SizedBox();
          final data = snap.data?.data() as Map<String, dynamic>?;
          final level = TrustLevelCalculator.calculate(
            totalPrograms: data?['totalPrograms'] ?? 0,
            totalBeneficiaries: data?['totalBeneficiaries'] ?? 0,
            totalRaised: (data?['totalRaised'] as num?)?.toDouble() ?? 0,
          );
          return TrustBadge(level: level);
        },
      ),
    ],
  );
}
