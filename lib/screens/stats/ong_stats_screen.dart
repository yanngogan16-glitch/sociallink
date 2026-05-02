import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/program_service.dart';
import '../../models/program_model.dart';
import '../../models/donation_model.dart';
import '../../theme/app_theme.dart';

class OngStatsScreen extends StatefulWidget {
  const OngStatsScreen({super.key});

  @override
  State<OngStatsScreen> createState() => _OngStatsScreenState();
}

class _OngStatsScreenState extends State<OngStatsScreen> {
  final ProgramService _programService = ProgramService();

  String _uid = '';
  String _ongName = '';
  bool _loading = true;

  // Stats
  int _totalPrograms = 0;
  int _activePrograms = 0;
  int _totalBeneficiaries = 0;
  double _totalRaised = 0;
  double _totalTarget = 0;
  List<ProgramModel> _programs = [];
  List<DonationModel> _recentDonations = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      _uid = user.uid;
      _ongName = userDoc.data()?['name'] ?? 'ONG';
    });

    // Charger programmes
    _programService.getOngPrograms(_uid).listen((programs) {
      double raised = 0;
      double target = 0;
      int beneficiaries = 0;

      for (final p in programs) {
        raised += p.raisedAmount;
        target += p.targetAmount;
        beneficiaries += p.spotsTaken;
      }

      setState(() {
        _programs = programs;
        _totalPrograms = programs.length;
        _activePrograms = programs.where((p) => p.status == 'active').length;
        _totalBeneficiaries = beneficiaries;
        _totalRaised = raised;
        _totalTarget = target;
        _loading = false;
      });
    });

    // Charger dons récents
    FirebaseFirestore.instance
        .collection('donations')
        .where('programId', whereIn: await _getMyProgramIds())
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .listen((snap) {
          setState(() {
            _recentDonations = snap.docs
                .map((doc) => DonationModel.fromFirestore(doc))
                .toList();
          });
        });
  }

  Future<List<String>> _getMyProgramIds() async {
    final snap = await FirebaseFirestore.instance
        .collection('programs')
        .where('ongId', isEqualTo: _uid)
        .get();
    return snap.docs.map((doc) => doc.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.gold)),
      );
    }

    final progressGlobal = _totalTarget > 0
        ? (_totalRaised / _totalTarget).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("STATISTIQUES"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header ONG
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.darkGoldGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _ongName.isNotEmpty ? _ongName[0].toUpperCase() : 'O',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bgDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppTheme.goldGradient.createShader(b),
                          child: Text(
                            _ongName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$_activePrograms programmes actifs",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Titre section
            _SectionTitle("Vue d'ensemble"),
            const SizedBox(height: 14),

            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: "Programmes",
                    value: "$_totalPrograms",
                    icon: Icons.campaign_outlined,
                    sublabel: "$_activePrograms actifs",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: "Beneficiaires",
                    value: "$_totalBeneficiaries",
                    icon: Icons.people_outline,
                    sublabel: "inscrits au total",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: "Fonds collectes",
                    value: _totalRaised.toStringAsFixed(0),
                    icon: Icons.account_balance_wallet_outlined,
                    sublabel: "FCFA",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: "Objectif total",
                    value: _totalTarget.toStringAsFixed(0),
                    icon: Icons.flag_outlined,
                    sublabel: "FCFA",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progression globale dons
            if (_totalTarget > 0) ...[
              _SectionTitle("Progression des dons"),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total collecte",
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "${(_totalRaised / _totalTarget * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progressGlobal,
                      color: AppTheme.gold,
                      backgroundColor: AppTheme.gold.withValues(alpha: 0.1),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_totalRaised.toStringAsFixed(0)} FCFA",
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "/ ${_totalTarget.toStringAsFixed(0)} FCFA",
                          style: const TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Programmes détail
            _SectionTitle("Mes programmes"),
            const SizedBox(height: 14),

            if (_programs.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Aucun programme",
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                ),
              )
            else
              ..._programs.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProgramStatCard(program: p),
                ),
              ),

            const SizedBox(height: 24),

            // Dons récents
            if (_recentDonations.isNotEmpty) ...[
              _SectionTitle("Dons recents"),
              const SizedBox(height: 14),
              ..._recentDonations.map(
                (don) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DonationRow(donation: don),
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Widgets locaux ──────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppTheme.textWhite,
      letterSpacing: 0.5,
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String sublabel;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.bgDark, size: 18),
        ),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textWhite,
          ),
        ),
        Text(
          sublabel,
          style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
        ),
      ],
    ),
  );
}

class _ProgramStatCard extends StatelessWidget {
  final ProgramModel program;
  const _ProgramStatCard({required this.program});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                program.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                program.category,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.bgDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Stats programme
        Row(
          children: [
            _MiniStat(
              icon: Icons.people_outline,
              value: "${program.spotsTaken}",
              label: "inscrits",
            ),
            const SizedBox(width: 16),
            _MiniStat(
              icon: Icons.event_seat_outlined,
              value: "${program.spotsLeft}",
              label: "places restantes",
            ),
            const SizedBox(width: 16),
            _MiniStat(
              icon: Icons.account_balance_wallet_outlined,
              value: program.raisedAmount.toStringAsFixed(0),
              label: "FCFA",
            ),
          ],
        ),

        if (program.targetAmount > 0) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: program.donationProgress,
            color: AppTheme.gold,
            backgroundColor: AppTheme.gold.withValues(alpha: 0.1),
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 6),
          Text(
            "${(program.donationProgress * 100).toStringAsFixed(1)}% de l'objectif atteint",
            style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
          ),
        ],
      ],
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 13, color: AppTheme.gold),
      const SizedBox(width: 4),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
          ),
        ],
      ),
    ],
  );
}

class _DonationRow extends StatelessWidget {
  final DonationModel donation;
  const _DonationRow({required this.donation});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.15)),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              donation.donorName.isNotEmpty
                  ? donation.donorName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 16,
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
                donation.donorName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(donation.createdAt),
                style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
              ),
            ],
          ),
        ),
        ShaderMask(
          shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
          child: Text(
            "+${donation.amount.toStringAsFixed(0)} FCFA",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
