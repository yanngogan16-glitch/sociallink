import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _smsCtrl = TextEditingController();
  final AuthService _auth = AuthService();

  bool _loading = false;
  bool _obscure = true;
  String _method = 'email'; // 'email' | 'google' | 'phone'
  String? _verificationId;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _smsCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) => setState(() => _error = msg);

  Future<void> _goToDashboard() async {
    final role = await _auth.getUserRole();
    if (!mounted) return;
    NavigationService.redirectByRole(context, role);
  }

  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.loginWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      if (mounted) await _goToDashboard();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cred = await _auth.signInWithGoogle();
      if (cred == null) return;
      if (mounted) await _goToDashboard();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendSms() async {
    if (_phoneCtrl.text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await _auth.sendSmsCode(
      phoneNumber: _phoneCtrl.text.trim(),
      onCodeSent: (id) => setState(() {
        _verificationId = id;
        _loading = false;
      }),
      onError: (e) => setState(() {
        _error = e;
        _loading = false;
      }),
    );
  }

  Future<void> _verifySms() async {
    if (_verificationId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.verifySmsCode(
        verificationId: _verificationId!,
        smsCode: _smsCtrl.text.trim(),
      );
      if (mounted) await _goToDashboard();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Back button ──
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppTheme.gold,
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── Header ──
                ShaderMask(
                  shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                  child: const Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.goldGradient,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Bienvenue sur SocialLink",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Sélecteur méthode ──
                Row(
                  children: [
                    _MethodTab(
                      label: "Email",
                      icon: Icons.email_outlined,
                      selected: _method == 'email',
                      onTap: () => setState(() => _method = 'email'),
                    ),
                    const SizedBox(width: 10),
                    _MethodTab(
                      label: "Google",
                      icon: Icons.g_mobiledata,
                      selected: _method == 'google',
                      onTap: () => setState(() => _method = 'google'),
                    ),
                    const SizedBox(width: 10),
                    _MethodTab(
                      label: "SMS",
                      icon: Icons.phone_outlined,
                      selected: _method == 'phone',
                      onTap: () => setState(() => _method = 'phone'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Erreur ──
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade700.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade400,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Formulaire selon méthode ──
                if (_method == 'email') _buildEmailForm(),
                if (_method == 'google') _buildGoogleForm(),
                if (_method == 'phone') _buildPhoneForm(),

                const SizedBox(height: 32),

                // ── Séparateur ──
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppTheme.gold.withOpacity(0.15)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        "ou",
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppTheme.gold.withOpacity(0.15)),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Lien inscription ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Pas encore de compte ? ",
                      style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: ShaderMask(
                        shaderCallback: (b) =>
                            AppTheme.goldGradient.createShader(b),
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Formulaire Email ──
  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _DarkInputField(
            controller: _emailCtrl,
            label: "Adresse email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v!.isEmpty ? "Email requis" : null,
          ),
          const SizedBox(height: 16),
          _DarkInputField(
            controller: _passwordCtrl,
            label: "Mot de passe",
            icon: Icons.lock_outline,
            obscure: _obscure,
            suffix: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textLight,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) => v!.length < 6 ? "Min. 6 caractères" : null,
          ),
          const SizedBox(height: 12),

          // Mot de passe oublié
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {}, // TODO: reset password
              child: Text(
                "Mot de passe oublié ?",
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.gold.withOpacity(0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _GoldButton(
            loading: _loading,
            label: "SE CONNECTER",
            onPressed: _loginEmail,
          ),
        ],
      ),
    );
  }

  // ── Formulaire Google ──
  Widget _buildGoogleForm() {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textWhite,
              side: BorderSide(color: AppTheme.gold.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.bgSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _loading ? null : _loginGoogle,
            child: _loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.gold,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "G",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "CONTINUER AVEC GOOGLE",
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ── Formulaire SMS ──
  Widget _buildPhoneForm() {
    return Column(
      children: [
        _DarkInputField(
          controller: _phoneCtrl,
          label: "Numéro de téléphone (+229...)",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        if (_verificationId != null) ...[
          _DarkInputField(
            controller: _smsCtrl,
            label: "Code SMS reçu",
            icon: Icons.sms_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          _GoldButton(
            loading: _loading,
            label: "VÉRIFIER LE CODE",
            onPressed: _verifySms,
          ),
        ] else ...[
          const SizedBox(height: 8),
          _GoldButton(
            loading: _loading,
            label: "ENVOYER LE CODE SMS",
            onPressed: _sendSms,
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════
// WIDGETS LOCAUX
// ═══════════════════════════════════════

class _MethodTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.goldGradient : null,
          color: selected ? null : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppTheme.gold.withOpacity(0.2),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppTheme.bgDark : AppTheme.textLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? AppTheme.bgDark : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DarkInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    validator: validator,
    style: const TextStyle(color: AppTheme.textWhite),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textLight),
      prefixIcon: Icon(icon, color: AppTheme.gold, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppTheme.bgSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.gold.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.gold.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade700),
      ),
    ),
  );
}

class _GoldButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback onPressed;

  const _GoldButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: loading ? null : AppTheme.goldGradient,
        color: loading ? AppTheme.bgSurface : null,
        borderRadius: BorderRadius.circular(30),
        boxShadow: loading
            ? null
            : [
                BoxShadow(
                  color: AppTheme.gold.withOpacity(0.35),
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
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.gold,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.bgDark,
                  letterSpacing: 2,
                ),
              ),
      ),
    ),
  );
}
