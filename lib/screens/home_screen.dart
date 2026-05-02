import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_scroll_item.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ══ HERO SECTION ══
            _HeroSection(context),

            // ══ STATS ══
            _StatsSection(),

            // ══ PRÉSENTATION ══
            _AboutSection(),

            // ══ RÔLES ══
            _RolesSection(context),

            // ══ FONCTIONNALITÉS ══
            _FeaturesSection(),

            // ══ CTA FINAL ══
            _FooterSection(context),
          ],
        ),
      ),
    );
  }

  Widget _HeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.bgDark,
            const Color(0xFF1A1500),
            AppTheme.bgDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.08),
                  width: 1),
              ),
            ),
          ),
          Positioned(
            top: 20, right: 20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.06),
                  width: 1),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.05),
                  width: 1),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Badge
                  AnimatedScrollItem(
                    delay: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.gold.withValues(
                            alpha: 0.4)),
                        borderRadius: BorderRadius.circular(20),
                        color: AppTheme.gold.withValues(
                          alpha: 0.08),
                      ),
                      child: const Text(
                        "✦  PLATEFORME HUMANITAIRE",
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        )),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Titre principal
                  AnimatedScrollItem(
                    delay: 100,
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Social",
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w300,
                              color: AppTheme.textWhite,
                              letterSpacing: 1,
                            )),
                          TextSpan(
                            text: "Link",
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                              letterSpacing: 1,
                            )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Ligne dorée
                  AnimatedScrollItem(
                    delay: 150,
                    child: Container(
                      width: 60, height: 2,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.goldGradient)),
                  ),
                  const SizedBox(height: 16),

                  // Sous-titre
                  AnimatedScrollItem(
                    delay: 200,
                    child: const Text(
                      "Connecter les ONG, bailleurs\n"
                      "et beneficiaires pour un\n"
                      "impact reel en Afrique.",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textLight,
                        height: 1.7,
                        letterSpacing: 0.3,
                      )),
                  ),
                  const SizedBox(height: 12),

                  // Étoiles décoratives
                  AnimatedScrollItem(
                    delay: 250,
                    child: Row(
                      children: List.generate(5, (i) =>
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.star,
                            size: 14,
                            color: AppTheme.gold.withValues(
                              alpha: 0.6 - i * 0.1)),
                        )),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Boutons hero
                  AnimatedScrollItem(
                    delay: 300,
                    child: Row(children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius:
                              BorderRadius.circular(30),
                            boxShadow: [BoxShadow(
                              color: AppTheme.gold.withValues(
                                alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                  BorderRadius.circular(30)),
                            ),
                            onPressed: () => Navigator.push(
                              context, MaterialPageRoute(
                                builder: (_) =>
                                  const RegisterScreen())),
                            child: const Text("COMMENCER",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.bgDark,
                                letterSpacing: 1.5,
                              )),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.gold,
                            side: BorderSide(
                              color: AppTheme.gold.withValues(
                                alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                BorderRadius.circular(30)),
                          ),
                          onPressed: () => Navigator.push(
                            context, MaterialPageRoute(
                              builder: (_) =>
                                const LoginScreen())),
                          child: const Text("CONNEXION",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            )),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _StatsSection() {
    final stats = [
      {"value": "120+", "label": "ONG", "icon": ""},
      {"value": "5K+", "label": "Bailleurs", "icon": ""},
      {"value": "30K+", "label": "Aides", "icon": ""},
      {"value": "15+", "label": "Pays", "icon": ""},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppTheme.gold.withValues(alpha: 0.12))),
        gradient: LinearGradient(
          colors: [
            AppTheme.bgDark,
            const Color(0xFF1A1400),
            AppTheme.bgDark,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.asMap().entries.map((e) =>
          AnimatedScrollItem(
            delay: e.key * 80,
            type: AnimationType.fadeScale,
            child: Column(children: [
              Text(e.value["icon"]!,
                style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              ShaderMask(
                shaderCallback: (b) =>
                  AppTheme.goldGradient.createShader(b),
                child: Text(e.value["value"]!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
              ),
              Text(e.value["label"]!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                  letterSpacing: 1,
                )),
            ]),
          ),
        ).toList(),
      ),
    );
  }

  Widget _AboutSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedScrollItem(
        delay: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.gold.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.05),
              blurRadius: 20,
            )],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("A PROPOS",
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.gold,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                )),
              const SizedBox(height: 12),
              const Text(
                "SocialLink est une plateforme humanitaire "
                "qui connecte les ONG, les bailleurs de fonds "
                "et les beneficiaires pour un impact reel "
                "en Afrique de l'Ouest.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textLight,
                  height: 1.8,
                )),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoChip(icon: "",
                    label: "ONG certifiees"),
                  _InfoChip(icon: "",
                    label: "Dons securises"),
                  _InfoChip(icon: "",
                    label: "Beneficiaires"),
                  _InfoChip(icon: "",
                    label: "Experts valides"),
                  _InfoChip(icon: "",
                    label: "Messagerie"),
                  _InfoChip(icon: "",
                    label: "Carte interactive"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _RolesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          AnimatedScrollItem(
            delay: 0,
            child: const Text("CHOISISSEZ VOTRE ROLE",
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.gold,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              )),
          ),
          const SizedBox(height: 8),
          AnimatedScrollItem(
            delay: 50,
            child: const Text("Qui etes-vous ?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.textWhite,
              )),
          ),
          const SizedBox(height: 20),

          AnimatedScrollItem(
            delay: 100,
            child: _LuxuryRoleCard(
              icon: Icons.volunteer_activism,
              title: "ONG",
              subtitle:
                "Creez et gerez vos programmes humanitaires",
              gradient: const LinearGradient(
                colors: [Color(0xFF1C1500), Color(0xFF2A2000)]),
              accentColor: const Color(0xFF1565C0),
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  const RegisterScreen())),
            ),
          ),
          const SizedBox(height: 14),

          AnimatedScrollItem(
            delay: 200,
            child: _LuxuryRoleCard(
              icon: Icons.favorite,
              title: "Bailleur / Personne Ressource",
              subtitle:
                "Soutenez des projets a fort impact social",
              gradient: const LinearGradient(
                colors: [Color(0xFF1A0A0A), Color(0xFF250D0D)]),
              accentColor: AppTheme.gold,
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  const RegisterScreen())),
            ),
          ),
          const SizedBox(height: 14),

          AnimatedScrollItem(
            delay: 300,
            child: _LuxuryRoleCard(
              icon: Icons.people_outline,
              title: "Beneficiaire",
              subtitle:
                "Accedez aux programmes d'aide disponibles",
              gradient: const LinearGradient(
                colors: [Color(0xFF0A0F1A), Color(0xFF0D1525)]),
              accentColor: Colors.green,
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  const RegisterScreen())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _FeaturesSection() {
    final features = [
      {"icon": "", "title": "Messagerie",
        "desc": "Echangez directement entre acteurs"},
      {"icon": "", "title": "Carte interactive",
        "desc": "Localisez les ONG et programmes"},
      {"icon": "", "title": "Systeme de dons",
        "desc": "Faites des dons securises en FCFA"},
      {"icon": "", "title": "Statistiques",
        "desc": "Suivez l'impact de vos actions"},
      {"icon": "", "title": "Notifications",
        "desc": "Restez informe en temps reel"},
      {"icon": "", "title": "Niveaux de confiance",
        "desc": "ONG certifiees bronze, argent, or"},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          AnimatedScrollItem(
            delay: 0,
            child: const Text("FONCTIONNALITES",
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.gold,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              )),
          ),
          const SizedBox(height: 8),
          AnimatedScrollItem(
            delay: 50,
            child: const Text("Tout ce dont vous avez besoin",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textWhite,
              )),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: features.asMap().entries.map((e) =>
              AnimatedScrollItem(
                delay: e.key * 80,
                type: AnimationType.fadeSlideUp,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.gold.withValues(
                        alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value["icon"]!,
                        style: const TextStyle(fontSize: 24)),
                      const Spacer(),
                      Text(e.value["title"]!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                        )),
                      const SizedBox(height: 4),
                      Text(e.value["desc"]!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textLight,
                          height: 1.4,
                        )),
                    ],
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _FooterSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [

          AnimatedScrollItem(
            delay: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppTheme.darkGoldGradient,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.1),
                  blurRadius: 20,
                )],
              ),
              child: Column(children: [
                const Text("",
                  style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (b) =>
                    AppTheme.goldGradient.createShader(b),
                  child: const Text(
                    "Rejoignez SocialLink",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50, height: 2,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.goldGradient)),
                const SizedBox(height: 12),
                const Text(
                  "Telechargez l'application et rejoignez\n"
                  "des milliers d'acteurs humanitaires.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                    height: 1.6,
                  )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(
                        color: AppTheme.gold.withValues(
                          alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                            BorderRadius.circular(30)),
                      ),
                      onPressed: () => Navigator.push(
                        context, MaterialPageRoute(
                          builder: (_) =>
                            const RegisterScreen())),
                      child: const Text(
                        "CREER UN COMPTE GRATUITEMENT",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bgDark,
                          letterSpacing: 1,
                        )),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const LoginScreen())),
                  child: RichText(
                    text: TextSpan(children: [
                      const TextSpan(
                        text: "Deja un compte ? ",
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 13)),
                      WidgetSpan(
                        child: ShaderMask(
                          shaderCallback: (b) =>
                            AppTheme.goldGradient.createShader(b),
                          child: const Text("Se connecter",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 30),

          // Footer
          AnimatedScrollItem(
            delay: 100,
            child: Column(children: [
              ShaderMask(
                shaderCallback: (b) =>
                  AppTheme.goldGradient.createShader(b),
                child: const Text("SocialLink ✦",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  )),
              ),
              const SizedBox(height: 6),
              const Text(
                "© 2026 — Ensemble pour un impact reel",
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                  letterSpacing: 1,
                )),
            ]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Widgets locaux ───────────────────────────────────

class _LuxuryRoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color accentColor;
  final VoidCallback onTap;

  const _LuxuryRoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )],
          ),
          child: Icon(icon,
            color: AppTheme.bgDark, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                  letterSpacing: 0.5,
                )),
              const SizedBox(height: 4),
              Text(subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  height: 1.4,
                )),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios,
          color: AppTheme.gold.withValues(alpha: 0.5),
          size: 14),
      ]),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppTheme.bgSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppTheme.gold.withValues(alpha: 0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 6),
      Text(label,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.textLight,
        )),
    ]),
  );
}