import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_scroll_item.dart';
import 'forms/ong_form.dart';
import 'forms/donor_form.dart';
import 'forms/beneficiary_form.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _selectedRole;

  final _roles = [
    {
      'key': 'ong',
      'label': 'ONG',
      'icon': Icons.volunteer_activism,
      'color': AppTheme.accent,
      'subtitle': 'Créez et gérez vos programmes',
    },
    {
      'key': 'donateur',
      'label': 'Donateur',
      'icon': Icons.favorite,
      'color': AppTheme.secondary,
      'subtitle': 'Soutenez des projets humanitaires',
    },
    {
      'key': 'beneficiaire',
      'label': 'Bénéficiaire',
      'icon': Icons.people,
      'color': AppTheme.primary,
      'subtitle': 'Accédez aux programmes d\'aide',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios, color: AppTheme.textDark),
              ),

              const SizedBox(height: 24),

              Text(
                "Créer un compte ",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Choisissez votre rôle pour commencer",
                style: TextStyle(fontSize: 14, color: AppTheme.textLight),
              ),

              const SizedBox(height: 28),

              // Sélection du rôle
              if (_selectedRole == null) ...[
                Text(
                  "Qui êtes-vous ?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                ..._roles.map(
                  (role) => AnimatedScrollItem(
                    delay: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _selectedRole = role['key'] as String,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.gold.withValues(alpha: 0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.gold.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  role['icon'] as IconData,
                                  color: AppTheme.gold,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role['label'] as String,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textWhite,
                                      ),
                                    ),
                                    Text(
                                      role['subtitle'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: AppTheme.gold.withValues(alpha: 0.65),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // Formulaire selon le rôle
              if (_selectedRole == 'ong') ...[
                _RoleHeader(
                  label: "ONG",
                  icon: Icons.volunteer_activism,
                  color: AppTheme.accent,
                  onBack: () => setState(() => _selectedRole = null),
                ),
                const SizedBox(height: 20),
                const OngForm(),
              ],

              if (_selectedRole == 'donateur') ...[
                _RoleHeader(
                  label: "Donateur",
                  icon: Icons.favorite,
                  color: AppTheme.secondary,
                  onBack: () => setState(() => _selectedRole = null),
                ),
                const SizedBox(height: 20),
                const BailleurForm(),
              ],

              if (_selectedRole == 'beneficiaire') ...[
                _RoleHeader(
                  label: "Bénéficiaire",
                  icon: Icons.people,
                  color: AppTheme.primary,
                  onBack: () => setState(() => _selectedRole = null),
                ),
                const SizedBox(height: 20),
                const BeneficiaryForm(),
              ],

              const SizedBox(height: 24),

              // Lien connexion
              if (_selectedRole == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Déjà un compte ? ",
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: Text(
                        "Se connecter",
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onBack;

  const _RoleHeader({
    required this.label,
    required this.icon,
    required this.color,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      GestureDetector(
        onTap: onBack,
        child: Icon(Icons.arrow_back_ios, size: 18, color: AppTheme.textDark),
      ),
      const SizedBox(width: 10),
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 8),
      Text(
        "Inscription $label",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ],
  );
}
