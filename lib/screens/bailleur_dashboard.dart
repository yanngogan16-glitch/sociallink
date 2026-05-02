import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/chat_service.dart';
import '../services/auth_guard.dart';
import '../widgets/animated_scroll_item.dart';
import 'programs/programs_list_screen.dart';
import 'resource/register_resource_screen.dart';
import 'chat/chats_list_screen.dart';
import 'donation/donation_history_screen.dart';
import 'search/search_screen.dart';

class BailleurDashboard extends StatelessWidget {
  const BailleurDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("TABLEAU Bailleurs / Personnes Ressources"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
        actions: [
          // ✅ Bouton recherche — séparé du StreamBuilder
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchScreen(viewerRole: 'donateur'),
              ),
            ),
            tooltip: "Rechercher",
          ),

          // ✅ Bouton messagerie avec badge
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
                title: "Bienvenue sur SocialLink",
                subtitle: "Votre aide change des vies",
                color: AppTheme.goldDark,
              ),
            ),
            const SizedBox(height: 24),

            const AnimatedScrollItem(
              delay: 0,
              child: SectionTitle("Projets a soutenir"),
            ),
            const SizedBox(height: 12),
            AnimatedScrollItem(
              delay: 0,
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ProgramsListScreen(viewerRole: 'donateur'),
                      ),
                    ),
                    child: const Text(
                      "VOIR TOUS LES PROGRAMMES",
                      style: TextStyle(
                        color: AppTheme.bgDark,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const AnimatedScrollItem(delay: 0, child: SectionTitle("Mes dons")),
            const SizedBox(height: 12),
            AnimatedScrollItem(
              delay: 0,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
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
                      builder: (_) => const DonationHistoryScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text(
                    "HISTORIQUE DE MES DONS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const AnimatedScrollItem(
              delay: 0,
              child: SectionTitle("Devenir Personne Ressource"),
            ),
            const SizedBox(height: 12),
            const AnimatedScrollItem(
              delay: 0,
              child: Text(
                "Medecin, psychologue, formateur... "
                "Rejoignez les ONG avec vos competences.",
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                  height: 1.5,
                ),
              ),
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
                      builder: (_) => const RegisterResourceScreen(),
                    ),
                  ),
                  child: const Text(
                    "DEVENIR PERSONNE RESSOURCE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
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
