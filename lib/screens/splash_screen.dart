import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/auth_guard.dart';
import '../services/navigation_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Dans SplashScreen, avant la redirection
    // Ajoute après initState

    // ✅ Écouter les changements d'auth
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        AuthGuard.clearCache(); // ✅ Vider le cache rôle
      }
    });
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final role = await _auth.getUserRole();
      if (!mounted) return;
      NavigationService.redirectByRole(context, role);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Stack(
          children: [
            // Cercles décoratifs
            Positioned(top: -80, right: -80, child: _GoldRing(size: 300)),
            Positioned(bottom: -60, left: -60, child: _GoldRing(size: 240)),

            // Contenu centré
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text("", style: TextStyle(fontSize: 44)),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Titre
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppTheme.goldGradient.createShader(b),
                        child: const Text(
                          "SocialLink",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Ligne or
                      Container(
                        width: 50,
                        height: 1.5,
                        decoration: const BoxDecoration(
                          gradient: AppTheme.goldGradient,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Ensemble pour un impact réel",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textLight,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Loader doré
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.gold.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldRing extends StatelessWidget {
  final double size;
  const _GoldRing({required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: AppTheme.gold.withValues(alpha: 0.07),
        width: 1.5,
      ),
    ),
  );
}
