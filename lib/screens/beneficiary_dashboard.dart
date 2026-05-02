import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/chat_service.dart';
import '../services/auth_guard.dart';
import '../widgets/animated_scroll_item.dart';
import 'programs/programs_list_screen.dart';
import 'chat/chats_list_screen.dart';
import 'search/search_screen.dart';

class BeneficiaryDashboard extends StatelessWidget {
  const BeneficiaryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("PROGRAMMES DISPONIBLES"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
        actions: [
          // ✅ Bouton recherche — séparé
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchScreen(viewerRole: 'beneficiaire'),
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
                title: "De l'aide pres de vous",
                subtitle: "Trouvez les programmes qui vous correspondent",
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 24),

            const AnimatedScrollItem(
              delay: 0,
              child: SectionTitle("Programmes disponibles"),
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
                        builder: (_) => const ProgramsListScreen(
                          viewerRole: 'beneficiaire',
                        ),
                      ),
                    ),
                    child: const Text(
                      "VOIR LES PROGRAMMES",
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
