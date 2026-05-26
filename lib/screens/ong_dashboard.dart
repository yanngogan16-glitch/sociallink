import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/donation_model.dart';
import '../models/program_model.dart';
import '../models/trust_level.dart';
import '../services/auth_guard.dart';
import '../services/chat_service.dart';
import '../services/donation_service.dart';
import '../services/program_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_scroll_item.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/trust_badge.dart';
import 'chat/chats_list_screen.dart';
import 'programs/create_program_screen.dart';
import 'resource/resources_list_screen.dart';
import 'search/search_screen.dart';
import 'stats/ong_stats_screen.dart';

class OngDashboard extends StatelessWidget {
  const OngDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final service = ProgramService();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("TABLEAU ONG"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: AppTheme.gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OngStatsScreen()),
            ),
            tooltip: "Statistiques",
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchScreen(viewerRole: 'ong'),
              ),
            ),
            tooltip: "Rechercher",
          ),
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
                            '$unread',
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
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.gold),
            onPressed: () async {
              AuthGuard.clearCache();
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              }
            },
            tooltip: "Se deconnecter",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedScrollItem(
              delay: 0,
              child: WelcomeBanner(
                title: "Bienvenue, ONG",
                subtitle: "Gerez vos programmes humanitaires",
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 24),
            _PendingDonationsSection(ongId: uid),

            const SizedBox(height: 24),
            const AnimatedScrollItem(
              delay: 0,
              child: SectionTitle("Mes Programmes"),
            ),
            const SizedBox(height: 12),
            AnimatedScrollItem(
              delay: 0,
              child: StreamBuilder<List<ProgramModel>>(
                stream: service.getOngPrograms(uid),
                builder: (context, snapshot) {
                  final programs = snapshot.data ?? [];
                  final totalBeneficiaries = programs.fold<int>(
                    0,
                    (sum, p) => sum + p.spotsTaken,
                  );
                  final totalRaised = programs.fold<double>(
                    0,
                    (sum, p) => sum + p.raisedAmount,
                  );

                  final level = TrustLevelCalculator.calculate(
                    totalPrograms: programs.length,
                    totalBeneficiaries: totalBeneficiaries,
                    totalRaised: totalRaised,
                  );

                  return TrustProgressCard(
                    currentLevel: level,
                    totalPrograms: programs.length,
                    totalBeneficiaries: totalBeneficiaries,
                    totalRaised: totalRaised,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const AnimatedScrollItem(
              delay: 0,
              child: SectionTitle("Personnes Ressources"),
            ),
            const SizedBox(height: 12),
            AnimatedScrollItem(
              delay: 0,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.gold,
                    side: BorderSide(
                      color: AppTheme.gold.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResourcesListScreen(),
                    ),
                  ),
                  child: const Text(
                    "TROUVER DES EXPERTS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.gold,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateProgramScreen()),
        ),
        icon: const Icon(Icons.add, color: AppTheme.bgDark),
        label: const Text(
          "Creer un programme",
          style: TextStyle(color: AppTheme.bgDark, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _PendingDonationsSection extends StatelessWidget {
  final String ongId;

  const _PendingDonationsSection({required this.ongId});

  @override
  Widget build(BuildContext context) {
    return AnimatedScrollItem(
      delay: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle("Dons a valider"),
          const SizedBox(height: 12),
          const _DonationInfoBox(
            message:
                "Pour chaque don recu, contactez le service client SocialLink afin de confirmer le paiement sur la plateforme avant validation.",
            color: AppTheme.gold,
          ),
          const SizedBox(height: 12),
          if (ongId.isEmpty)
            const _DonationInfoBox(
              message: "Connectez-vous avec un compte ONG pour voir les dons.",
              color: Colors.orange,
            )
          else
            StreamBuilder<List<DonationModel>>(
              stream: DonationService().getPendingDonationsForOng(ongId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.gold),
                  );
                }

                if (snapshot.hasError) {
                  return _DonationInfoBox(
                    message:
                        "Impossible de charger les dons a valider : ${snapshot.error}",
                    color: Colors.red,
                  );
                }

                final dons = snapshot.data ?? [];
                if (dons.isEmpty) {
                  return const _DonationInfoBox(
                    message: "Aucun don en attente de validation",
                    color: AppTheme.gold,
                  );
                }

                return Column(
                  children: dons
                      .map((don) => _PendingDonationCard(don: don))
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DonationInfoBox extends StatelessWidget {
  final String message;
  final Color color;

  const _DonationInfoBox({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textLight),
      ),
    );
  }
}

class _PendingDonationCard extends StatefulWidget {
  final DonationModel don;

  const _PendingDonationCard({required this.don});

  @override
  State<_PendingDonationCard> createState() => _PendingDonationCardState();
}

class _PendingDonationCardState extends State<_PendingDonationCard> {
  bool _loading = false;

  DonationModel get don => widget.don;

  Future<void> _handleAction({
    required Future<void> Function() action,
    required String successMessage,
    required Color successColor,
  }) async {
    setState(() => _loading = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Action impossible : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                don.donorName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              ShaderMask(
                shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                child: Text(
                  "${don.amount.toStringAsFixed(0)} FCFA",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            don.programTitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
          if (don.message.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              don.message,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: _loading
                      ? null
                      : () => _handleAction(
                          action: () =>
                              DonationService().confirmDonation(don.id),
                          successMessage: "Don confirme !",
                          successColor: Colors.green,
                        ),
                  child: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "VALIDER LE DON",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: _loading
                      ? null
                      : () => _handleAction(
                          action: () =>
                              DonationService().rejectDonation(don.id),
                          successMessage: "Don rejete.",
                          successColor: Colors.red,
                        ),
                  child: const Text(
                    "REJETER",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
