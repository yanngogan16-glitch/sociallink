import 'package:flutter/material.dart';
import '../../models/resource_person_model.dart';
import '../../services/resource_person_service.dart';
import '../../theme/app_theme.dart';
import 'resource_detail_screen.dart';

class ResourcesListScreen extends StatefulWidget {
  const ResourcesListScreen({super.key});

  @override
  State<ResourcesListScreen> createState() => _ResourcesListScreenState();
}

class _ResourcesListScreenState extends State<ResourcesListScreen> {
  final ResourcePersonService _service = ResourcePersonService();
  String _selectedSpecialty = 'Tous';

  final List<String> _specialties = [
    'Tous',
    'Psychologue / Thérapeute',
    'Avocat / Juriste',
    'Formateur / Enseignant',
    'Ingénieur / Technicien',
    'Comptable / Financier',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("Personnes Ressources"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
      ),
      body: Column(children: [

        // Filtre spécialités
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
            itemCount: _specialties.length,
            itemBuilder: (_, i) {
              final s = _specialties[i];
              final selected = s == _selectedSpecialty;
              return GestureDetector(
                onTap: () =>
                  setState(() => _selectedSpecialty = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: selected
                      ? AppTheme.goldGradient : null,
                    color: selected
                      ? null : AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                        ? Colors.transparent
                        : AppTheme.gold.withValues(alpha: 0.2)),
                  ),
                  child: Text(s,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected
                        ? FontWeight.bold : FontWeight.normal,
                      color: selected
                        ? AppTheme.bgDark : AppTheme.textLight,
                    )),
                ),
              );
            },
          ),
        ),

        // Liste
        Expanded(
          child: StreamBuilder<List<ResourcePersonModel>>(
            stream: _service.getAvailablePersons(
              specialty: _selectedSpecialty == 'Tous'
                ? null : _selectedSpecialty,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.gold));
              }

              final persons = snapshot.data ?? [];

              if (persons.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("✦", style: TextStyle(
                        fontSize: 40, color: AppTheme.gold)),
                      SizedBox(height: 12),
                      Text("Aucune personne ressource disponible",
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 15)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: persons.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ResourceCard(
                    person: persons[i],
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                        ResourceDetailScreen(person: persons[i]))),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final ResourcePersonModel person;
  final VoidCallback onTap;

  const _ResourceCard({
    required this.person,
    required this.onTap,
  });

  String get _modeIcon {
    switch (person.interventionMode) {
      case 'presentiel': return '';
      case 'enligne': return '';
      default: return '';
    }
  }

  String get _compensationLabel {
    switch (person.compensationType) {
      case 'benevole': return 'Bénévole';
      case 'compense': return 'Rémunéré';
      default: return 'Flexible';
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              person.name.isNotEmpty
                ? person.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.bgDark,
              )),
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                )),
              const SizedBox(height: 4),
              Text(
                person.specialty == 'Autre'
                  ? person.otherSpecialty
                  : person.specialty,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.gold,
                )),
              const SizedBox(height: 6),
              Row(children: [
                Text("$_modeIcon  ",
                  style: const TextStyle(fontSize: 11)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.3)),
                  ),
                  child: Text(_compensationLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w600,
                    )),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_outlined,
                  size: 11, color: AppTheme.textLight),
                Text(person.location,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textLight,
                  )),
              ]),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppTheme.gold),
      ]),
    ),
  );
}