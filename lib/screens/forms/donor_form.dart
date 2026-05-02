import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import '../../theme/app_theme.dart';
import 'form_widgets.dart'; // ✅ seul import nécessaire

class BailleurForm extends StatefulWidget {
  const BailleurForm({super.key});

  @override
  State<BailleurForm> createState() => _BailleurFormState();
}

class _BailleurFormState extends State<BailleurForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final AuthService _auth = AuthService();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        role: 'donateur',
        extraData: {
          'name': _nameCtrl.text.trim(),
          'country': _countryCtrl.text.trim(),
        },
      );
      if (mounted) NavigationService.redirectByRole(context, 'donateur');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_error != null) AppErrorBox(message: _error!), // ✅

          AppFormField(
            ctrl: _nameCtrl,
            label: "Nom complet", // ✅
            icon: Icons.person_outline,
            validator: (v) => v!.isEmpty ? "Requis" : null,
          ),
          const SizedBox(height: 14),

          AppFormField(
            ctrl: _countryCtrl,
            label: "Pays",
            icon: Icons.flag_outlined,
            validator: (v) => v!.isEmpty ? "Requis" : null,
          ),
          const SizedBox(height: 14),

          AppFormField(
            ctrl: _emailCtrl,
            label: "Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v!.isEmpty ? "Requis" : null,
          ),
          const SizedBox(height: 14),

          AppFormField(
            ctrl: _passwordCtrl,
            label: "Mot de passe",
            icon: Icons.lock_outline,
            obscure: _obscure,
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) => v!.length < 6 ? "Min. 6 caractères" : null,
          ),
          const SizedBox(height: 24),

          AppSubmitButton(
            // ✅
            loading: _loading,
            label: "Créer mon compte Donateur",
            color: AppTheme.secondary,
            onPressed: _register,
          ),
        ],
      ),
    );
  }
}
