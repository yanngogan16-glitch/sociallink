import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../theme/app_theme.dart';
class AuthGuard {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? _cachedRole;

  static bool get isLoggedIn => _auth.currentUser != null;

  // ✅ Récupérer et cacher le rôle
  static Future<String?> getRole() async {
    if (_cachedRole != null) return _cachedRole;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance
      .collection('users').doc(uid).get();
    _cachedRole = doc.data()?['role'] as String?;
    return _cachedRole;
  }

  // ✅ Vider le cache à la déconnexion
  static void clearCache() => _cachedRole = null;

  // ✅ Vérifier si connecté — sinon popup
  static bool checkAuth(BuildContext context) {
    if (!isLoggedIn) {
      _showAuthDialog(context);
      return false;
    }
    return true;
  }

  // ✅ Vérifier le rôle exact
  static Future<bool> checkRole(
      BuildContext context, String requiredRole) async {
    if (!isLoggedIn) {
      _showAuthDialog(context);
      return false;
    }
    final role = await getRole();
    if (role != requiredRole) {
      _showWrongRoleDialog(context, role);
      return false;
    }
    return true;
  }

  // ✅ Dialog connexion requise
  static void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        title: ShaderMask(
          shaderCallback: (b) =>
            AppTheme.goldGradient.createShader(b),
          child: const Text("Connexion requise",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        ),
        content: const Text(
          "Vous devez etre connecte pour "
          "effectuer cette action.",
          style: TextStyle(color: AppTheme.textLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler",
              style: TextStyle(color: AppTheme.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const RegisterScreen()));
            },
            child: const Text("S'inscrire",
              style: TextStyle(
                color: AppTheme.bgDark,
                fontWeight: FontWeight.bold,
              )),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const LoginScreen()));
            },
            child: const Text("Se connecter",
              style: TextStyle(color: AppTheme.gold)),
          ),
        ],
      ),
    );
  }

  // ✅ Dialog mauvais rôle
  static void _showWrongRoleDialog(
      BuildContext context, String? currentRole) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.red.withValues(alpha: 0.3)),
        ),
        title: const Text("Acces refuse",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          )),
        content: Text(
          "Votre compte est un compte "
          "${currentRole ?? 'inconnu'}. "
          "Deconnectez-vous pour changer de role.",
          style: const TextStyle(color: AppTheme.textLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK",
              style: TextStyle(color: AppTheme.gold)),
          ),
        ],
      ),
    );
  }
}

