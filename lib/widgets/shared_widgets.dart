import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WelcomeBanner extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  const WelcomeBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color, color.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(
          fontSize: 13, color: Colors.white70)),
    ]),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: AppTheme.textWhite, // ✅ corrigé
    ));
}

class ProgramCard extends StatelessWidget {
  final String title, location;
  final int beneficiaries;
  final Color color;
  const ProgramCard({
    super.key,
    required this.title,
    required this.location,
    required this.beneficiaries,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15), // ✅
        child: Icon(Icons.campaign, color: color)),
      title: Text(title, style: const TextStyle(
          fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
      subtitle: Text(" $location  •   $beneficiaries bénéficiaires",
        style: const TextStyle(color: AppTheme.textLight)),
      trailing: Icon(Icons.chevron_right, color: color),
    ),
  );
}

class DonationCard extends StatelessWidget {
  final String title, ong, raised, goal;
  final double progress;
  final Color color;
  const DonationCard({
    super.key,
    required this.title,
    required this.ong,
    required this.progress,
    required this.raised,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.textWhite)),
        const SizedBox(height: 4),
        Text(ong, style: const TextStyle(
            color: AppTheme.textLight, fontSize: 13)),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: color.withValues(alpha: 0.15), // ✅
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(raised, style: TextStyle(
              color: color, fontWeight: FontWeight.bold)),
          Text("/ $goal", style: const TextStyle(
              color: AppTheme.textLight)),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () {},
            child: const Text("Faire un don",
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    ),
  );
}

class BenefitCard extends StatelessWidget {
  final String title, ong, location;
  final int spots;
  final Color color;
  const BenefitCard({
    super.key,
    required this.title,
    required this.ong,
    required this.location,
    required this.spots,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.textWhite)),
        const SizedBox(height: 4),
        Text("$ong  •   $location",
          style: const TextStyle(
              color: AppTheme.textLight, fontSize: 13)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), // ✅
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("$spots places restantes",
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
            ),
            onPressed: () {},
            child: const Text("S'inscrire",
                style: TextStyle(color: Colors.white)),
          ),
        ]),
      ]),
    ),
  );
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08), // ✅
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)), // ✅
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class ImpactChip extends StatelessWidget {
  final String icon, value, label;
  const ImpactChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.2)), // ✅
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.gold)),
        Text(label, style: const TextStyle(
            fontSize: 10, color: AppTheme.textLight),
          textAlign: TextAlign.center),
      ]),
    ),
  );
}