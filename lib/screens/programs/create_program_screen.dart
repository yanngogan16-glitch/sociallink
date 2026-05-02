import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program_model.dart';
import '../../services/program_service.dart';
import '../../theme/app_theme.dart';

class CreateProgramScreen extends StatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _spotsCtrl = TextEditingController();
  final ProgramService _service = ProgramService();

  String _category = 'Alimentation';
  bool _loading = false;
  String? _error;

  final List<String> _categories = [
    'Alimentation',
    'Éducation',
    'Santé',
    'Eau potable',
    'Formation',
    'Logement',
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
      // Récupérer le nom de l'ONG
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final ongName = userDoc.data()?['name'] ?? 'ONG';

      final program = ProgramModel(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        location: _locationCtrl.text.trim(),
        ongId: user.uid,
        ongName: ongName,
        targetAmount: double.tryParse(_targetCtrl.text) ?? 0,
        raisedAmount: 0,
        spotsTotal: int.tryParse(_spotsCtrl.text) ?? 0,
        spotsTaken: 0,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _service.createProgram(program);
      if (mounted) Navigator.pop(context);
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
        title: const Text("Nouveau Programme"),
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
                  "Créer un programme ✦",
                  style: TextStyle(
                    fontSize: 22,
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

              _GoldField(
                ctrl: _titleCtrl,
                label: "Titre du programme",
                icon: Icons.title,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 16),

              _GoldField(
                ctrl: _descCtrl,
                label: "Description",
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 16),

              // Catégorie
              _LabelText("Catégorie"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  dropdownColor: AppTheme.bgSurface,
                  style: const TextStyle(color: AppTheme.textWhite),
                  underline: const SizedBox(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.gold,
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ),
              const SizedBox(height: 16),

              _GoldField(
                ctrl: _locationCtrl,
                label: "Localisation (ville, pays)",
                icon: Icons.location_on_outlined,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _GoldField(
                      ctrl: _targetCtrl,
                      label: "Objectif (FCFA)",
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _GoldField(
                      ctrl: _spotsCtrl,
                      label: "Places dispo",
                      icon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                  ),
                ],
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
                            "PUBLIER LE PROGRAMME",
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

// ── Widgets locaux ──────────────────────────

class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textLight,
      fontSize: 13,
      letterSpacing: 0.5,
    ),
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
