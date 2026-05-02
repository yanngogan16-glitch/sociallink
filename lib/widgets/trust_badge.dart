import 'package:flutter/material.dart';
import '../models/trust_level.dart';

class TrustBadge extends StatelessWidget {
  final TrustLevel level;
  final bool showLabel;

  const TrustBadge({
    super.key,
    required this.level,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(level.color);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: 8,
        )],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(level.icon,
          style: const TextStyle(fontSize: 14)),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(level.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            )),
        ],
      ]),
    );
  }
}

class TrustProgressCard extends StatelessWidget {
  final TrustLevel currentLevel;
  final int totalPrograms;
  final int totalBeneficiaries;
  final double totalRaised;

  const TrustProgressCard({
    super.key,
    required this.currentLevel,
    required this.totalPrograms,
    required this.totalBeneficiaries,
    required this.totalRaised,
  });

  TrustLevel? get _nextLevel {
    switch (currentLevel) {
      case TrustLevel.bronze: return TrustLevel.silver;
      case TrustLevel.silver: return TrustLevel.gold;
      case TrustLevel.gold: return TrustLevel.platinum;
      case TrustLevel.platinum: return null;
    }
  }

  double get _progressToNext {
    switch (currentLevel) {
      case TrustLevel.bronze:
        return (totalPrograms / 3).clamp(0.0, 1.0);
      case TrustLevel.silver:
        return (totalPrograms / 10).clamp(0.0, 1.0);
      case TrustLevel.gold:
        return (totalPrograms / 20).clamp(0.0, 1.0);
      case TrustLevel.platinum:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(currentLevel.color);
    final next = _nextLevel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(
          color: color.withValues(alpha: 0.1),
          blurRadius: 16,
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header niveau actuel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("NIVEAU DE CONFIANCE",
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9E9E9E),
                      letterSpacing: 2,
                    )),
                  const SizedBox(height: 6),
                  Text(
                    "${currentLevel.icon} ${currentLevel.label}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    )),
                ],
              ),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                    width: 2),
                ),
                child: Center(
                  child: Text(currentLevel.icon,
                    style: const TextStyle(fontSize: 26))),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats
          Row(children: [
            _MiniStat(
              value: totalPrograms.toString(),
              label: "Programmes"),
            const SizedBox(width: 20),
            _MiniStat(
              value: totalBeneficiaries.toString(),
              label: "Beneficiaires"),
            const SizedBox(width: 20),
            _MiniStat(
              value: "${totalRaised.toStringAsFixed(0)} F",
              label: "Collectes"),
          ]),

          if (next != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Progression vers ${next.label}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  )),
                Text(
                  "${(_progressToNext * 100)
                    .toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  )),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _progressToNext,
              color: color,
              backgroundColor: color.withValues(alpha: 0.1),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(next.description,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9E9E9E),
              )),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Text(currentLevel.icon,
                  style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                const Text("Niveau maximum atteint !",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  )),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD4AF37),
        )),
      Text(label,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF9E9E9E),
        )),
    ],
  );
}