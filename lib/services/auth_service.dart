import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Utilisateur courant
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ✅ Inscription Email + Mot de passe
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> extraData,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Sauvegarder le profil dans Firestore
      await _saveUserProfile(
        uid: cred.user!.uid,
        email: email,
        role: role,
        extraData: extraData,
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Connexion Email + Mot de passe
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final UserCredential cred;

      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        cred = await _auth.signInWithPopup(provider);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await _auth.signInWithCredential(credential);
      }
      // Créer profil si nouveau
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) {
        await _saveUserProfile(
          uid: cred.user!.uid,
          email: cred.user!.email ?? '',
          role: 'donateur', // rôle par défaut Google
          extraData: {'name': cred.user!.displayName ?? ''},
        );
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception("Erreur Google Sign-In : $e");
    }
  }

  // ✅ SMS — Envoi du code
  Future<void> sendSmsCode({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? "Erreur vérification");
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // ✅ SMS — Vérification du code
  Future<UserCredential?> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Déconnexion
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // 🔧 Sauvegarder profil Firestore
  Future<void> _saveUserProfile({
    required String uid,
    required String email,
    required String role,
    required Map<String, dynamic> extraData,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      ...extraData,
    });
  }

  /// Retourne le rôle utilisateur stocké dans Firestore.
  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return '';
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return '';
    final data = doc.data();
    return (data != null && data['role'] is String)
        ? data['role'] as String
        : '';
  }

  // 🔧 Gestion erreurs
  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email déjà utilisé.";
      case 'invalid-email':
        return "Email invalide.";
      case 'weak-password':
        return "Mot de passe trop faible.";
      case 'user-not-found':
        return "Aucun compte trouvé.";
      case 'wrong-password':
        return "Mot de passe incorrect.";
      default:
        return e.message ?? "Erreur inconnue.";
    }
  }
}
