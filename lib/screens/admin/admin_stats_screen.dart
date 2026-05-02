import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  final _db = FirebaseFirestore.instance;
  bool _loading = true;

  int _totalUsers = 0;
  int _totalOngs = 0;
  int _totalDonateurs = 0;
  int _totalBeneficiaires = 0;
  int _totalPrograms = 0;
  int _totalDonations = 0;
  double _totalAmount = 0;
  int _totalResources = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final users = await _db.collection('users').get();
    final programs = await _db.collection('programs').get();
    final donations = await _db.collection('donations').get();
    final resources = await _db.collection('resource_persons').get();

    double amount = 0;
    for (final doc in donations.docs) {
      final data = doc.data();
      amount += (data['amount'] as num?)?.toDouble() ?? 0;
    }

    setState(() {
      _totalUsers = users.docs.length;
      _totalOngs = users.docs
        .where((d) => d.data()['role'] == 'ong').length;
      _totalDonateurs = users.docs
        .where((d) => d.data()['role'] == 'donateur').length;
      _totalBeneficiaires = users.docs
        .where((d) => d.data()['role'] == 'beneficiaire').length;
      _totalPrograms = programs.docs.length;
      _totalDonations = donations.docs.length;
      _totalAmount = amount;
      _totalResources = resources.docs.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(child: CircularProgressIndicator(
          color: AppTheme.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("STATISTIQUES GLOBALES"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("UTILISATEURS",
              style: TextStyle(
                fontSize: 11, color: AppTheme.gold,
                letterSpacing: 3, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _StatBox(
                label: "Total", value: _totalUsers.toString(),
                color: Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(
                label: "ONG", value: _totalOngs.toString(),
                color: AppTheme.gold)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _StatBox(
                label: "Bailleurs",
                value: _totalDonateurs.toString(),
                color: Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(
                label: "Beneficiaires",
                value: _totalBeneficiaires.toString(),
                color: Colors.purple)),
            ]),
            const SizedBox(height: 24),

            const Text("ACTIVITE",
              style: TextStyle(
                fontSize: 11, color: AppTheme.gold,
                letterSpacing: 3, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _StatBox(
                label: "Programmes",
                value: _totalPrograms.toString(),
                color: Colors.teal)),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(
                label: "Experts",
                value: _totalResources.toString(),
                color: Colors.orange)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _StatBox(
                label: "Dons",
                value: _totalDonations.toString(),
                color: AppTheme.gold)),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(
                label: "FCFA collectes",
                value: _totalAmount.toStringAsFixed(0),
                color: Colors.green)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(
            fontSize: 12, color: AppTheme.textLight)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (b) =>
            LinearGradient(colors: [color, color.withValues(alpha: 0.7)])
              .createShader(b),
          child: Text(value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        ),
      ],
    ),
  );
}