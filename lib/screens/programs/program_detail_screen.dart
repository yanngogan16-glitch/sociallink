import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program_model.dart';
import '../../services/program_service.dart';
import '../../theme/app_theme.dart';
import '../donation/donation_screen.dart'; // ✅ ajouté
import '../../widgets/trust_badge.dart';
import '../../models/trust_level.dart';

class ProgramDetailScreen extends StatefulWidget {
  final ProgramModel program;
  final String viewerRole;
  const ProgramDetailScreen({
    super.key,
    required this.program,
    required this.viewerRole,
  });

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  final ProgramService _service = ProgramService();
  bool _loading = false;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final registered = await _service.isRegistered(
      programId: widget.program.id,
      userId: uid,
    );
    setState(() => _registered = registered);
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['name'] ?? 'Bénéficiaire';

      await _service.registerBeneficiary(
        programId: widget.program.id,
        userId: user.uid,
        userName: userName,
      );
      setState(() => _registered = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Inscription réussie !"),
            backgroundColor: AppTheme.gold,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.program;
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
        title: const Text("Détail programme"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge catégorie
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                p.category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.bgDark,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            Text(
              p.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textWhite,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 50,
              height: 2,
              decoration: const BoxDecoration(gradient: AppTheme.goldGradient),
            ),
            const SizedBox(height: 16),

            // ONG & Localisation
            _OngTrustRow(program: p),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.location_on_outlined, text: p.location),
            const SizedBox(height: 24),

            // Description
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gold,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  if (p.targetAmount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Dons collectés",
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "${p.raisedAmount.toStringAsFixed(0)} / "
                          "${p.targetAmount.toStringAsFixed(0)} FCFA",
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: p.donationProgress,
                      color: AppTheme.gold,
                      backgroundColor: AppTheme.gold.withValues(alpha: 0.1),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Places disponibles",
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "${p.spotsLeft} / ${p.spotsTotal}",
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bouton Bénéficiaire
            if (widget.viewerRole == 'beneficiaire')
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: (_loading || _registered)
                        ? null
                        : AppTheme.goldGradient,
                    color: (_loading || _registered)
                        ? AppTheme.bgSurface
                        : null,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: (_loading || _registered)
                        ? null
                        : [
                            BoxShadow(
                              color: AppTheme.gold.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: (_loading || _registered) ? null : _register,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.gold,
                            ),
                          )
                        : Text(
                            _registered
                                ? "DEJA INSCRIT"
                                : "S'INSCRIRE AU PROGRAMME",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _registered
                                  ? AppTheme.gold
                                  : AppTheme.bgDark,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
              ),

            // ✅ Bouton Bailleur — DON réel
            if (widget.viewerRole == 'donateur')
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    // ✅ Navigation vers DonationScreen
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DonationScreen(program: widget.program),
                      ),
                    ),
                    child: const Text(
                      "FAIRE UN DON",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.bgDark,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 15, color: AppTheme.gold),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
      ),
    ],
  );
}

class _OngTrustRow extends StatelessWidget {
  final ProgramModel program;

  const _OngTrustRow({required this.program});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.business, size: 15, color: AppTheme.gold),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          program.ongName,
          style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
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
