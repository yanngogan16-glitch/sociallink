import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/resource_person_model.dart';
import '../../services/chat_service.dart'; // ✅ ajouté
import '../../theme/app_theme.dart';
import '../chat/chat_screen.dart';

class ResourceDetailScreen extends StatelessWidget {
  final ResourcePersonModel person;
  const ResourceDetailScreen({super.key, required this.person});

  String get _modeLabel {
    switch (person.interventionMode) {
      case 'presentiel':
        return ' Présentiel';
      case 'enligne':
        return ' En ligne';
      default:
        return ' Présentiel & En ligne';
    }
  }

  String get _compensationLabel {
    switch (person.compensationType) {
      case 'benevole':
        return ' Bénévole';
      case 'compense':
        return ' Rémunéré';
      default:
        return ' Bénévole ou Rémunéré';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
        title: const Text("Profil Personne Ressource"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + nom
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gold.withValues(alpha: 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        person.name.isNotEmpty
                            ? person.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bgDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppTheme.goldGradient.createShader(b),
                    child: Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    person.specialty == 'Autre'
                        ? person.otherSpecialty
                        : person.specialty,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Chips infos
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoChip(label: _modeLabel),
                _InfoChip(label: _compensationLabel),
                _InfoChip(label: " ${person.location}"),
                _InfoChip(label: " ${person.availability}"),
                if (person.compensationAmount != null)
                  _InfoChip(
                    label:
                        " ${person.compensationAmount!.toStringAsFixed(0)} FCFA/jour",
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Bio
            _SectionTitle("À propos"),
            const SizedBox(height: 10),
            Text(
              person.bio,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 24),

            // Contact
            _SectionTitle("Contact"),
            const SizedBox(height: 10),
            _ContactRow(icon: Icons.phone_outlined, text: person.phone),
            const SizedBox(height: 8),
            _ContactRow(icon: Icons.email_outlined, text: person.email),
            const SizedBox(height: 32),

            // ✅ Bouton CONTACTER — messagerie réelle
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.3),
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
                  // ✅ onPressed avec vraie messagerie
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser!;
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();
                    final myName = userDoc.data()?['name'] ?? 'Utilisateur';

                    final chatService = ChatService();
                    final chatId = await chatService.getOrCreateChat(
                      otherUid: person.userId,
                      otherName: person.name,
                      myName: myName,
                    );

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId,
                            otherUid: person.userId,
                            otherName: person.name,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "CONTACTER ",
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      color: AppTheme.gold,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppTheme.bgSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
    ),
  );
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: AppTheme.gold),
      const SizedBox(width: 10),
      Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
      ),
    ],
  );
}
