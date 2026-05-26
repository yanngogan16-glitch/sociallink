import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program_model.dart';
import '../../services/donation_service.dart';
import '../../theme/app_theme.dart';

class DonationScreen extends StatefulWidget {
  final ProgramModel program;
  const DonationScreen({super.key, required this.program});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _amountCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final DonationService _service = DonationService();

  double? _selectedAmount;
  String _paymentMethod = 'mobile_money';
  bool _loading = false;
  String? _error;

  // Montants prédéfinis en FCFA
  final List<double> _presetAmounts = [1000, 2500, 5000, 10000, 25000, 50000];

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'key': 'mobile_money',
      'label': 'Mobile Money',
      'icon': Icons.phone_android,
      'desc': 'MTN, Moov, Wave...',
    },
    {
      'key': 'carte',
      'label': 'Carte bancaire',
      'icon': Icons.credit_card,
      'desc': 'Visa, Mastercard',
    },
    {
      'key': 'virement',
      'label': 'Virement',
      'icon': Icons.account_balance,
      'desc': 'Virement bancaire',
    },
  ];

  Future<void> _submit() async {
    final amount =
        _selectedAmount ??
        double.tryParse(_amountCtrl.text.replaceAll(' ', ''));

    if (amount == null || amount <= 0) {
      setState(() => _error = "Veuillez entrer un montant valide");
      return;
    }

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
      final donorName = userDoc.data()?['name'] ?? 'Anonyme';

      await _service.makeDonation(
        programId: widget.program.id,
        programTitle: widget.program.title,
        ongId: widget.program.ongId,
        ongName: widget.program.ongName,
        donorName: donorName,
        amount: amount,
        paymentMethod: _paymentMethod,
        message: _messageCtrl.text.trim(),
      );
      if (mounted) {
        _showSuccess(amount);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSuccess(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top,
                  color: AppTheme.bgDark,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                child: const Text(
                  "Don en attente",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${amount.toStringAsFixed(0)} FCFA",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Votre don pour ${widget.program.title} est en attente de confirmation par l'ONG.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
              ),
              const SizedBox(height: 8),
              const Text(
                "L'ONG doit contacter le service client SocialLink pour confirmer le paiement sur la plateforme.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // ferme dialog
                      Navigator.pop(context); // retour dashboard
                    },
                    child: const Text(
                      "RETOUR",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.bgDark,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.program.donationProgress;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("FAIRE UN DON"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header programme
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.program.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.bgDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.program.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.program.ongName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: progress,
                    color: AppTheme.gold,
                    backgroundColor: AppTheme.gold.withValues(alpha: 0.1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.program.raisedAmount.toStringAsFixed(0)} FCFA collectés",
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Objectif : ${widget.program.targetAmount.toStringAsFixed(0)} FCFA",
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
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

            // Montants prédéfinis
            _SectionLabel("Choisir un montant"),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: _presetAmounts.map((amount) {
                final selected = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAmount = amount;
                      _amountCtrl.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: selected ? AppTheme.goldGradient : null,
                      color: selected ? null : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : AppTheme.gold.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k FCFA",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? AppTheme.bgDark
                              : AppTheme.textWhite,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Montant libre
            _SectionLabel("Ou entrer un montant"),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textWhite),
              onChanged: (_) => setState(() => _selectedAmount = null),
              decoration: InputDecoration(
                hintText: "Ex: 15000",
                hintStyle: TextStyle(
                  color: AppTheme.textLight.withValues(alpha: 0.5),
                ),
                suffixText: "FCFA",
                suffixStyle: const TextStyle(color: AppTheme.gold),
                filled: true,
                fillColor: AppTheme.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.gold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Méthode de paiement
            _SectionLabel("Méthode de paiement"),
            const SizedBox(height: 12),
            ..._paymentMethods.map((method) {
              final selected = _paymentMethod == method['key'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _paymentMethod = method['key']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.gold.withValues(alpha: 0.08)
                          : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppTheme.gold
                            : AppTheme.gold.withValues(alpha: 0.2),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: selected ? AppTheme.goldGradient : null,
                            color: selected ? null : AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            method['icon'] as IconData,
                            color: selected
                                ? AppTheme.bgDark
                                : AppTheme.textLight,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['label'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: selected
                                      ? AppTheme.gold
                                      : AppTheme.textWhite,
                                ),
                              ),
                              Text(
                                method['desc'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppTheme.bgDark,
                              size: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Message optionnel
            _SectionLabel("Message (optionnel)"),
            const SizedBox(height: 10),
            TextFormField(
              controller: _messageCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: InputDecoration(
                hintText: "Un mot d'encouragement...",
                hintStyle: TextStyle(
                  color: AppTheme.textLight.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppTheme.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.gold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Bouton confirmer
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
                          "CONFIRMER LE DON",
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      color: AppTheme.gold,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );
}
