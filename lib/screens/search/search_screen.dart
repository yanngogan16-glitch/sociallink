import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program_model.dart';
import '../../models/resource_person_model.dart';
import '../../theme/app_theme.dart';
import '../programs/program_detail_screen.dart';
import '../resource/resource_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String viewerRole;
  const SearchScreen({super.key, required this.viewerRole});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  // Filtres programmes
  String _programCategory = 'Tous';
  String _programLocation = '';

  // Filtres personnes ressources
  String _resourceSpecialty = 'Tous';
  String _resourceMode = 'Tous';
  String _resourceLocation = '';

  // Résultats
  List<ProgramModel> _programs = [];
  List<ResourcePersonModel> _resources = [];
  bool _loadingPrograms = false;
  bool _loadingResources = false;
  bool _hasSearched = false;

  final List<String> _categories = [
    'Tous', 'Alimentation', 'Education',
    'Sante', 'Eau potable', 'Formation', 'Logement',
  ];

  final List<String> _specialties = [
    'Tous',
    'Psychologue / Therapeute',
    'Avocat / Juriste',
    'Formateur / Enseignant',
    'Ingenieur / Technicien',
    'Comptable / Financier',
    'Autre',
  ];

  final List<String> _modes = [
    'Tous', 'presentiel', 'enligne', 'les deux',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ✅ Recherche programmes
  Future<void> _searchPrograms() async {
    setState(() { _loadingPrograms = true; _hasSearched = true; });

    try {
      Query query = FirebaseFirestore.instance
        .collection('programs')
        .where('status', isEqualTo: 'active');

      if (_programCategory != 'Tous') {
        query = query.where('category',
          isEqualTo: _programCategory);
      }

      final snap = await query.get();
      var results = snap.docs
        .map((doc) => ProgramModel.fromFirestore(doc))
        .toList();

      // Filtre texte local
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        results = results.where((p) =>
          p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.ongName.toLowerCase().contains(q)
        ).toList();
      }

      // Filtre localisation local
      if (_programLocation.isNotEmpty) {
        results = results.where((p) =>
          p.location.toLowerCase().contains(
            _programLocation.toLowerCase())
        ).toList();
      }

      setState(() => _programs = results);
    } catch (e) {
      debugPrint("Erreur recherche programmes : $e");
    } finally {
      setState(() => _loadingPrograms = false);
    }
  }

  // ✅ Recherche personnes ressources
  Future<void> _searchResources() async {
    setState(() { _loadingResources = true; _hasSearched = true; });

    try {
      Query query = FirebaseFirestore.instance
        .collection('resource_persons')
        .where('isAvailable', isEqualTo: true);

      if (_resourceSpecialty != 'Tous') {
        query = query.where('specialty',
          isEqualTo: _resourceSpecialty);
      }

      if (_resourceMode != 'Tous') {
        query = query.where('interventionMode',
          isEqualTo: _resourceMode);
      }

      final snap = await query.get();
      var results = snap.docs
        .map((doc) => ResourcePersonModel.fromFirestore(doc))
        .toList();

      // Filtre texte local
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        results = results.where((r) =>
          r.name.toLowerCase().contains(q) ||
          r.specialty.toLowerCase().contains(q) ||
          r.bio.toLowerCase().contains(q)
        ).toList();
      }

      // Filtre localisation local
      if (_resourceLocation.isNotEmpty) {
        results = results.where((r) =>
          r.location.toLowerCase().contains(
            _resourceLocation.toLowerCase())
        ).toList();
      }

      setState(() => _resources = results);
    } catch (e) {
      debugPrint("Erreur recherche ressources : $e");
    } finally {
      setState(() => _loadingResources = false);
    }
  }

  void _search() {
    if (_tabController.index == 0) {
      _searchPrograms();
    } else {
      _searchResources();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("RECHERCHE"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.gold,
          labelColor: AppTheme.gold,
          unselectedLabelColor: AppTheme.textLight,
          onTap: (_) {
            if (_hasSearched) _search();
          },
          tabs: const [
            Tab(text: "PROGRAMMES"),
            Tab(text: "PERSONNES RESSOURCES"),
          ],
        ),
      ),
      body: Column(
        children: [

          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              border: Border(bottom: BorderSide(
                color: AppTheme.gold.withValues(alpha: 0.15))),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: AppTheme.textWhite),
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: "Rechercher...",
                    hintStyle: TextStyle(
                      color: AppTheme.textLight.withValues(alpha: 0.6)),
                    prefixIcon: const Icon(Icons.search,
                      color: AppTheme.gold, size: 20),
                    filled: true,
                    fillColor: AppTheme.bgCard,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppTheme.gold.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppTheme.gold.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppTheme.gold, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _search,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.3),
                      blurRadius: 8,
                    )],
                  ),
                  child: const Icon(Icons.search,
                    color: AppTheme.bgDark, size: 20),
                ),
              ),
            ]),
          ),

          // Contenu tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Programmes
                _ProgramsTab(
                  programs: _programs,
                  loading: _loadingPrograms,
                  hasSearched: _hasSearched,
                  viewerRole: widget.viewerRole,
                  selectedCategory: _programCategory,
                  categories: _categories,
                  locationCtrl: _programLocation,
                  onCategoryChanged: (v) =>
                    setState(() => _programCategory = v),
                  onLocationChanged: (v) =>
                    setState(() => _programLocation = v),
                  onSearch: _searchPrograms,
                ),

                // Tab Personnes Ressources
                _ResourcesTab(
                  resources: _resources,
                  loading: _loadingResources,
                  hasSearched: _hasSearched,
                  selectedSpecialty: _resourceSpecialty,
                  selectedMode: _resourceMode,
                  specialties: _specialties,
                  modes: _modes,
                  locationCtrl: _resourceLocation,
                  onSpecialtyChanged: (v) =>
                    setState(() => _resourceSpecialty = v),
                  onModeChanged: (v) =>
                    setState(() => _resourceMode = v),
                  onLocationChanged: (v) =>
                    setState(() => _resourceLocation = v),
                  onSearch: _searchResources,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Programmes ──────────────────────────────────

class _ProgramsTab extends StatelessWidget {
  final List<ProgramModel> programs;
  final bool loading;
  final bool hasSearched;
  final String viewerRole;
  final String selectedCategory;
  final List<String> categories;
  final String locationCtrl;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onSearch;

  const _ProgramsTab({
    required this.programs,
    required this.loading,
    required this.hasSearched,
    required this.viewerRole,
    required this.selectedCategory,
    required this.categories,
    required this.locationCtrl,
    required this.onCategoryChanged,
    required this.onLocationChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Filtres
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.bgDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Filtre catégorie
              const Text("Categorie",
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  letterSpacing: 0.5,
                )),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final sel = cat == selectedCategory;
                    return GestureDetector(
                      onTap: () => onCategoryChanged(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: sel
                            ? AppTheme.goldGradient : null,
                          color: sel ? null : AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                              ? Colors.transparent
                              : AppTheme.gold.withValues(alpha: 0.2)),
                        ),
                        child: Text(cat,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: sel
                              ? FontWeight.bold : FontWeight.normal,
                            color: sel
                              ? AppTheme.bgDark : AppTheme.textLight,
                          )),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Filtre localisation
              _LocationField(
                value: locationCtrl,
                onChanged: onLocationChanged,
                onSearch: onSearch,
              ),
            ],
          ),
        ),

        // Résultats
        Expanded(
          child: loading
            ? const Center(child: CircularProgressIndicator(
                color: AppTheme.gold))
            : !hasSearched
              ? _EmptyState(
                  icon: Icons.search,
                  message: "Lancez une recherche\npour voir les programmes",
                )
              : programs.isEmpty
                ? _EmptyState(
                    icon: Icons.search_off,
                    message: "Aucun programme trouve",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: programs.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProgramSearchCard(
                        program: programs[i],
                        viewerRole: viewerRole,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}

// ── Tab Personnes Ressources ────────────────────────

class _ResourcesTab extends StatelessWidget {
  final List<ResourcePersonModel> resources;
  final bool loading;
  final bool hasSearched;
  final String selectedSpecialty;
  final String selectedMode;
  final List<String> specialties;
  final List<String> modes;
  final String locationCtrl;
  final ValueChanged<String> onSpecialtyChanged;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onSearch;

  const _ResourcesTab({
    required this.resources,
    required this.loading,
    required this.hasSearched,
    required this.selectedSpecialty,
    required this.selectedMode,
    required this.specialties,
    required this.modes,
    required this.locationCtrl,
    required this.onSpecialtyChanged,
    required this.onModeChanged,
    required this.onLocationChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Filtres
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.bgDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Filtre spécialité
              const Text("Specialite",
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  letterSpacing: 0.5,
                )),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: specialties.length,
                  itemBuilder: (_, i) {
                    final s = specialties[i];
                    final sel = s == selectedSpecialty;
                    return GestureDetector(
                      onTap: () => onSpecialtyChanged(s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: sel
                            ? AppTheme.goldGradient : null,
                          color: sel ? null : AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                              ? Colors.transparent
                              : AppTheme.gold.withValues(alpha: 0.2)),
                        ),
                        child: Text(s,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: sel
                              ? FontWeight.bold : FontWeight.normal,
                            color: sel
                              ? AppTheme.bgDark : AppTheme.textLight,
                          )),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Filtre mode
              const Text("Mode d'intervention",
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  letterSpacing: 0.5,
                )),
              const SizedBox(height: 8),
              Row(children: modes.map((mode) {
                final sel = mode == selectedMode;
                final label = mode == 'presentiel' ? 'Presentiel'
                  : mode == 'enligne' ? 'En ligne'
                  : mode == 'les deux' ? 'Les deux' : 'Tous';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onModeChanged(mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: sel
                          ? AppTheme.goldGradient : null,
                        color: sel ? null : AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                            ? Colors.transparent
                            : AppTheme.gold.withValues(alpha: 0.2)),
                      ),
                      child: Text(label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: sel
                            ? FontWeight.bold : FontWeight.normal,
                          color: sel
                            ? AppTheme.bgDark : AppTheme.textLight,
                        )),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 12),

              // Filtre localisation
              _LocationField(
                value: locationCtrl,
                onChanged: onLocationChanged,
                onSearch: onSearch,
              ),
            ],
          ),
        ),

        // Résultats
        Expanded(
          child: loading
            ? const Center(child: CircularProgressIndicator(
                color: AppTheme.gold))
            : !hasSearched
              ? _EmptyState(
                  icon: Icons.person_search,
                  message: "Lancez une recherche\npour voir les experts",
                )
              : resources.isEmpty
                ? _EmptyState(
                    icon: Icons.search_off,
                    message: "Aucune personne ressource trouvee",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: resources.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ResourceSearchCard(
                        person: resources[i],
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}

// ── Widgets partagés ────────────────────────────────

class _LocationField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearch;

  const _LocationField({
    required this.value,
    required this.onChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) => TextField(
    style: const TextStyle(color: AppTheme.textWhite),
    onChanged: onChanged,
    onSubmitted: (_) => onSearch(),
    decoration: InputDecoration(
      hintText: "Filtrer par ville / pays...",
      hintStyle: TextStyle(
        color: AppTheme.textLight.withValues(alpha: 0.5),
        fontSize: 13,
      ),
      prefixIcon: const Icon(Icons.location_on_outlined,
        color: AppTheme.gold, size: 18),
      filled: true,
      fillColor: AppTheme.bgCard,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppTheme.gold, width: 1.5),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48,
          color: AppTheme.gold.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 14,
            height: 1.6,
          )),
      ],
    ),
  );
}

class _ProgramSearchCard extends StatelessWidget {
  final ProgramModel program;
  final String viewerRole;
  const _ProgramSearchCard({
    required this.program,
    required this.viewerRole,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context,
      MaterialPageRoute(builder: (_) => ProgramDetailScreen(
        program: program,
        viewerRole: viewerRole,
      ))),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.campaign,
            color: AppTheme.bgDark, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(program.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(program.category,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.bgDark,
                    )),
                ),
                const SizedBox(width: 8),
                Icon(Icons.location_on_outlined,
                  size: 11, color: AppTheme.textLight),
                Text(program.location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  )),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.people_outline,
                  size: 12, color: AppTheme.gold),
                const SizedBox(width: 4),
                Text("${program.spotsLeft} places",
                  style: const TextStyle(
                    fontSize: 11, color: AppTheme.gold)),
                const SizedBox(width: 12),
                Icon(Icons.account_balance_wallet_outlined,
                  size: 12, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(
                  "${program.raisedAmount.toStringAsFixed(0)} FCFA",
                  style: const TextStyle(
                    fontSize: 11, color: AppTheme.textLight)),
              ]),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios,
          size: 14, color: AppTheme.gold.withValues(alpha: 0.5)),
      ]),
    ),
  );
}

class _ResourceSearchCard extends StatelessWidget {
  final ResourcePersonModel person;
  const _ResourceSearchCard({required this.person});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context,
      MaterialPageRoute(builder: (_) =>
        ResourceDetailScreen(person: person))),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              person.name.isNotEmpty
                ? person.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 18,
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                )),
              const SizedBox(height: 4),
              Text(
                person.specialty == 'Autre'
                  ? person.otherSpecialty : person.specialty,
                style: const TextStyle(
                  fontSize: 12, color: AppTheme.gold)),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.location_on_outlined,
                  size: 11, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(person.location,
                  style: const TextStyle(
                    fontSize: 11, color: AppTheme.textLight)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    person.compensationType == 'benevole'
                      ? 'Benevole'
                      : person.compensationType == 'compense'
                        ? 'Remunere' : 'Flexible',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w600,
                    )),
                ),
              ]),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios,
          size: 14,
          color: AppTheme.gold.withValues(alpha: 0.5)),
      ]),
    ),
  );
}