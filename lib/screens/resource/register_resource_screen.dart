import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/resource_person_model.dart';
import '../../services/resource_person_service.dart';
import '../../theme/app_theme.dart';

class RegisterResourceScreen extends StatefulWidget {
  const RegisterResourceScreen({super.key});

  @override
  State<RegisterResourceScreen> createState() => _RegisterResourceScreenState();
}

class _RegisterResourceScreenState extends State<RegisterResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _availabilityCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();
  final _compensationCtrl = TextEditingController();
  final ResourcePersonService _service = ResourcePersonService();

  String _specialty = 'Psychologue / Thérapeute';
  String _interventionMode = 'les deux';
  String _compensationType = 'benevole';
  bool _loading = false;
  String? _error;

  final List<String> _specialties = [
    'Psychologue / Thérapeute',
    'Avocat / Juriste',
    'Formateur / Enseignant',
    'Ingénieur / Technicien',
    'Comptable / Financier',
    'Autre',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final email = userDoc.data()?['email'] ?? user.email ?? '';

      final person = ResourcePersonModel(
        id: '',
        userId: user.uid,
        name: _nameCtrl.text.trim(),
        specialty: _specialty,
        otherSpecialty: _specialty == 'Autre' ? _otherCtrl.text.trim() : '',
        bio: _bioCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        interventionMode: _interventionMode,
        compensationType: _compensationType,
        compensationAmount: _compensationType != 'benevole'
            ? double.tryParse(_compensationCtrl.text)
            : null,
        availability: _availabilityCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: email,
        createdAt: DateTime.now(),
      );

      await _service.registerAsResourcePerson(person);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil créé avec succès ! "),
            backgroundColor: AppTheme.gold,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("Devenir Personne Ressource"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ShaderMask(
                shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                child: const Text(
                  "Votre profil ",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
              const SizedBox(height: 6),
              const Text(
                "Rejoignez les ONG en tant qu'expert bénévole "
                "ou rémunéré",
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Erreur
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red.shade700.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade300),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Infos personnelles
              _SectionHeader(" Informations personnelles"),
              const SizedBox(height: 14),

              _GoldField(
                ctrl: _nameCtrl,
                label: "Nom complet",
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 14),

              _GoldField(
                ctrl: _bioCtrl,
                label: "Biographie / Expérience",
                icon: Icons.notes,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 14),

              _GoldField(
                ctrl: _locationCtrl,
                label: "Ville / Pays",
                icon: Icons.location_on_outlined,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 14),

              _GoldField(
                ctrl: _phoneCtrl,
                label: "Numéro de téléphone",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 24),

              // Spécialité
              _SectionHeader(" Compétence"),
              const SizedBox(height: 14),

              _GoldDropdown(
                value: _specialty,
                items: _specialties,
                label: "Spécialité",
                icon: Icons.work_outline,
                onChanged: (v) => setState(() => _specialty = v!),
              ),

              if (_specialty == 'Autre') ...[
                const SizedBox(height: 14),
                _GoldField(
                  ctrl: _otherCtrl,
                  label: "Précisez votre spécialité",
                  icon: Icons.edit_outlined,
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),
              ],
              const SizedBox(height: 24),

              // Mode d'intervention
              _SectionHeader(" Mode d'intervention"),
              const SizedBox(height: 14),

              Row(
                children: [
                  _SelectChip(
                    label: "Présentiel",
                    icon: Icons.place_outlined,
                    selected: _interventionMode == 'presentiel',
                    onTap: () =>
                        setState(() => _interventionMode = 'presentiel'),
                  ),
                  const SizedBox(width: 10),
                  _SelectChip(
                    label: "En ligne",
                    icon: Icons.videocam_outlined,
                    selected: _interventionMode == 'enligne',
                    onTap: () => setState(() => _interventionMode = 'enligne'),
                  ),
                  const SizedBox(width: 10),
                  _SelectChip(
                    label: "Les deux",
                    icon: Icons.swap_horiz,
                    selected: _interventionMode == 'les deux',
                    onTap: () => setState(() => _interventionMode = 'les deux'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Compensation
              _SectionHeader(" Type de participation"),
              const SizedBox(height: 14),

              Row(
                children: [
                  _SelectChip(
                    label: "Bénévole",
                    icon: Icons.volunteer_activism,
                    selected: _compensationType == 'benevole',
                    onTap: () => setState(() => _compensationType = 'benevole'),
                  ),
                  const SizedBox(width: 10),
                  _SelectChip(
                    label: "Rémunéré",
                    icon: Icons.payments_outlined,
                    selected: _compensationType == 'compense',
                    onTap: () => setState(() => _compensationType = 'compense'),
                  ),
                  const SizedBox(width: 10),
                  _SelectChip(
                    label: "Les deux",
                    icon: Icons.tune,
                    selected: _compensationType == 'les deux',
                    onTap: () => setState(() => _compensationType = 'les deux'),
                  ),
                ],
              ),

              if (_compensationType != 'benevole') ...[
                const SizedBox(height: 14),
                _GoldField(
                  ctrl: _compensationCtrl,
                  label: "Tarif journalier (FCFA) — optionnel",
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 24),

              // Disponibilité
              _SectionHeader(" Disponibilité"),
              const SizedBox(height: 14),

              _GoldField(
                ctrl: _availabilityCtrl,
                label: "Ex: Weekends, 2 fois/mois...",
                icon: Icons.calendar_today_outlined,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 32),

              // Bouton soumettre
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _loading ? null : AppTheme.goldGradient,
                    color: _loading ? AppTheme.bgSurface : null,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: _loading
                        ? null
                        : [
                            BoxShadow(
                              color: AppTheme.gold.withValues(alpha: 0.35),
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
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.gold,
                            ),
                          )
                        : const Text(
                            "SOUMETTRE MON PROFIL ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.bgDark,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets locaux ─────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppTheme.textWhite,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        width: 30,
        height: 1.5,
        decoration: const BoxDecoration(gradient: AppTheme.goldGradient),
      ),
    ],
  );
}

class _GoldField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _GoldField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    style: const TextStyle(color: AppTheme.textWhite),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textLight),
      prefixIcon: Icon(icon, color: AppTheme.gold, size: 20),
      filled: true,
      fillColor: AppTheme.bgSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
      ),
    ),
  );
}

class _GoldDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final String label;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _GoldDropdown({
    required this.value,
    required this.items,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.bgSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: AppTheme.bgSurface,
            style: const TextStyle(color: AppTheme.textWhite),
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.gold),
            items: items
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

class _SelectChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
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
                : AppTheme.gold.withValues(alpha: 0.25),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppTheme.bgDark : AppTheme.textLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
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
