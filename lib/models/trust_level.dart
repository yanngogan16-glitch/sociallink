enum TrustLevel {
  bronze,
  silver,
  gold,
  platinum,
}

extension TrustLevelExtension on TrustLevel {
  String get label {
    switch (this) {
      case TrustLevel.bronze: return 'Bronze';
      case TrustLevel.silver: return 'Argent';
      case TrustLevel.gold: return 'Or';
      case TrustLevel.platinum: return 'Platine';
    }
  }

  String get icon {
    switch (this) {
      case TrustLevel.bronze: return '🥉';
      case TrustLevel.silver: return '🥈';
      case TrustLevel.gold: return '🥇';
      case TrustLevel.platinum: return '💎';
    }
  }

  int get color {
    switch (this) {
      case TrustLevel.bronze: return 0xFFCD7F32;
      case TrustLevel.silver: return 0xFFC0C0C0;
      case TrustLevel.gold: return 0xFFD4AF37;
      case TrustLevel.platinum: return 0xFFE5E4E2;
    }
  }

  String get description {
    switch (this) {
      case TrustLevel.bronze:
        return '1 programme cree';
      case TrustLevel.silver:
        return '3 programmes + 5 beneficiaires';
      case TrustLevel.gold:
        return '10 programmes + 50 beneficiaires';
      case TrustLevel.platinum:
        return '20 programmes + 200 beneficiaires';
    }
  }
}

class TrustLevelCalculator {
  static TrustLevel calculate({
    required int totalPrograms,
    required int totalBeneficiaries,
    required double totalRaised,
  }) {
    if (totalPrograms >= 20 && totalBeneficiaries >= 200) {
      return TrustLevel.platinum;
    } else if (totalPrograms >= 10 && totalBeneficiaries >= 50) {
      return TrustLevel.gold;
    } else if (totalPrograms >= 3 && totalBeneficiaries >= 5) {
      return TrustLevel.silver;
    } else {
      return TrustLevel.bronze;
    }
  }
}