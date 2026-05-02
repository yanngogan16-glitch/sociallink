import 'package:flutter/material.dart';
import '../screens/ong_dashboard.dart';
import '../screens/bailleur_dashboard.dart';
import '../screens/beneficiary_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/login_screen.dart';

class NavigationService {
  static void redirectByRole(BuildContext context, String? role) {
    Widget destination;
    switch (role) {
      case 'ong':
        destination = const OngDashboard();
        break;
      case 'donateur':
        destination = const BailleurDashboard();
        break;
      case 'beneficiaire':
        destination = const BeneficiaryDashboard();
        break;
      case 'admin':
        destination = const AdminDashboard();
        break;
      default:
        destination = const LoginScreen();
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }
}
