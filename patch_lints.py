from pathlib import Path

root = Path('lib')

# Add extension helper to app theme
app_theme = root / 'theme' / 'app_theme.dart'
text = app_theme.read_text(encoding='utf-8')
if 'withOpacityValue' not in text:
    idx = text.rfind('}')
    if idx != -1:
        text = (
            text[:idx]
            + "\n\nextension AppThemeColorHelpers on Color {\n"
            + "  Color withOpacityValue(double opacity) => withAlpha((opacity * 255).round());\n"
            + "}\n"
            + text[idx:]
        )
    else:
        text += "\n\nextension AppThemeColorHelpers on Color {\n"
        text += "  Color withOpacityValue(double opacity) => withAlpha((opacity * 255).round());\n"
        text += "}\n"
    app_theme.write_text(text, encoding='utf-8')

# Replace deprecated withOpacity with withOpacityValue
for path in root.rglob('*.dart'):
    text = path.read_text(encoding='utf-8')
    if '.withOpacity(' in text:
        path.write_text(text.replace('.withOpacity(', '.withOpacityValue('), encoding='utf-8')

# Fix donation form createState and build context usage
path = root / 'screens' / 'donation' / 'donation_form.dart'
text = path.read_text(encoding='utf-8')
text = text.replace(
    '@override\n  _DonationFormState createState() => _DonationFormState();',
    '@override\n  State<DonationForm> createState() => _DonationFormState();',
)
text = text.replace(
    '        await _donationService.createDonation(\n'
    '          programId: widget.programId,\n'
    '          amount: amount,\n'
    '          paymentMethod: _paymentMethod,\n'
    '          notes: _messageController.text,\n'
    '        );\n\n'
    '        ScaffoldMessenger.of(\n'
    '          context,\n'
    '        ).showSnackBar(SnackBar(content: Text(\'Donation successful!\')));',
    '        await _donationService.createDonation(\n'
    '          programId: widget.programId,\n'
    '          amount: amount,\n'
    '          paymentMethod: _paymentMethod,\n'
    '          notes: _messageController.text,\n'
    '        );\n\n'
    '        if (!mounted) return;\n'
    '        ScaffoldMessenger.of(\n'
    '          context,\n'
    '        ).showSnackBar(SnackBar(content: Text(\'Donation successful!\')));',
)
text = text.replace(
    '      } catch (e) {\n'
    '        ScaffoldMessenger.of(\n'
    '          context,\n'
    '        ).showSnackBar(SnackBar(content: Text(\'Error making donation: $e\')));',
    '      } catch (e) {\n'
    '        if (!mounted) return;\n'
    '        ScaffoldMessenger.of(\n'
    '          context,\n'
    '        ).showSnackBar(SnackBar(content: Text(\'Error making donation: $e\')));',
)
path.write_text(text, encoding='utf-8')

# Rename donation model fields and constructor parameters
path = root / 'models' / 'donation_model.dart'
text = path.read_text(encoding='utf-8')
text = text.replace('  final String BailleurId;\n  final String BailleurName;', '  final String bailleurId;\n  final String bailleurName;')
text = text.replace(
    '    required this.BailleurId,\n    required this.BailleurName,',
    '    required this.bailleurId,\n    required this.bailleurName,',
)
text = text.replace(
    """      BailleurId: d['BailleurId'] ?? '',
      BailleurName: d['BailleurName'] ?? '',""",
    """      bailleurId: d['BailleurId'] ?? '',
      bailleurName: d['BailleurName'] ?? '',""",
)
text = text.replace(
    "    'BailleurId': BailleurId,\n"
    "    'BailleurName': BailleurName,",
    "    'BailleurId': bailleurId,\n"
    "    'BailleurName': bailleurName,",
)
path.write_text(text, encoding='utf-8')

# Rename donation service parameters and field usage
path = root / 'services' / 'donation_service.dart'
text = path.read_text(encoding='utf-8')
text = text.replace('    required String BailleurName,', '    required String bailleurName,')
text = text.replace(
    '        BailleurId: _myUid,\n'
    '        BailleurName: BailleurName,',
    '        bailleurId: _myUid,\n'
    '        bailleurName: bailleurName,',
)
text = text.replace('      BailleurName: BailleurName,', '      bailleurName: bailleurName,')
text = text.replace(
    'return snap.docs.fold<double>(0, (sum, doc) {\n'
    '      final data = doc.data();\n'
    '      return sum + ((data[\'amount\'] as num?)?.toDouble() ?? 0);\n'
    '    });',
    'return snap.docs.fold<double>(0, (total, doc) {\n'
    '      final data = doc.data();\n'
    '      return total + ((data[\'amount\'] as num?)?.toDouble() ?? 0);\n'
    '    });',
)
path.write_text(text, encoding='utf-8')

# Rename donation screen variable
path = root / 'screens' / 'donation' / 'donation_screen.dart'
text = path.read_text(encoding='utf-8')
text = text.replace("      final BailleurName = userDoc.data()?['name'] ?? 'Anonyme';", "      final bailleurName = userDoc.data()?['name'] ?? 'Anonyme';")
text = text.replace('        BailleurName: BailleurName,', '        bailleurName: bailleurName,')
path.write_text(text, encoding='utf-8')

# Rename home screen helper method names
path = root / 'screens' / 'home_screen.dart'
text = path.read_text(encoding='utf-8')
text = text.replace('_HeroSection()', '_heroSection()')
text = text.replace('_RolesSection(context)', '_rolesSection(context)')
text = text.replace('_StatsSection()', '_statsSection()')
text = text.replace('_FooterSection(context)', '_footerSection(context)')
text = text.replace('Widget _HeroSection()', 'Widget _heroSection()')
text = text.replace('Widget _RolesSection(BuildContext context)', 'Widget _rolesSection(BuildContext context)')
text = text.replace('Widget _StatsSection()', 'Widget _statsSection()')
text = text.replace('Widget _FooterSection(BuildContext context)', 'Widget _footerSection(BuildContext context)')
path.write_text(text, encoding='utf-8')

# Rename chat service fold parameter
path = root / 'services' / 'chat_service.dart'
text = path.read_text(encoding='utf-8')
text = text.replace(
    'snap.docs.fold<int>(0, (sum, doc) {\n'
    '        final data = doc.data();\n'
    '        final counts = Map<String, dynamic>.from(\n'
    '          data[\'unreadCounts\'] ?? {});\n'
    '        return sum + ((counts[_myUid] as int?) ?? 0);\n'
    '      }));',
    'snap.docs.fold<int>(0, (total, doc) {\n'
    '        final data = doc.data();\n'
    '        final counts = Map<String, dynamic>.from(\n'
    '          data[\'unreadCounts\'] ?? {});\n'
    '        return total + ((counts[_myUid] as int?) ?? 0);\n'
    '      }));',
)
path.write_text(text, encoding='utf-8')

# Fix notification service generic syntax
path = root / 'services' / 'notification_service.dart'
text = path.read_text(encoding='utf-8')
text = text.replace(
    '.resolvePlatformSpecificImplementation\n        AndroidFlutterLocalNotificationsPlugin>()',
    '.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()',
)
path.write_text(text, encoding='utf-8')

print('patches applied')
