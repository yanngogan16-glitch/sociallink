import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/program_model.dart';
import '../../services/program_service.dart';
import '../../theme/app_theme.dart';
import '../programs/program_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final String viewerRole;
  const MapScreen({super.key, required this.viewerRole});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final ProgramService _service = ProgramService();

  Position? _userPosition;
  List<ProgramModel> _programs = [];
  String _selectedCategory = 'Tous';
  bool _loading = true;
  ProgramModel? _selectedProgram;

  // Centrage initial — Cotonou, Bénin
  static final LatLng _initialCenter = LatLng(6.3702, 2.3931);

  final List<String> _categories = [
    'Tous',
    'Alimentation',
    'Éducation',
    'Santé',
    'Eau potable',
    'Formation',
    'Logement',
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadPrograms();
  }

  // ✅ Géolocalisation
  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() => _userPosition = pos);

      // Centrer sur l'utilisateur
      _mapController.move(LatLng(pos.latitude, pos.longitude), 12);
    } catch (e) {
      debugPrint("Erreur géolocalisation : $e");
    }
  }

  // ✅ Charger programmes Firestore
  void _loadPrograms() {
    _service.getActivePrograms().listen((programs) {
      setState(() {
        _programs = programs;
        _loading = false;
      });
    });
  }

  // ✅ Programmes filtrés
  List<ProgramModel> get _filteredPrograms {
    if (_selectedCategory == 'Tous') return _programs;
    return _programs.where((p) => p.category == _selectedCategory).toList();
  }

  // ✅ Programmes avec coordonnées
  List<ProgramModel> get _mappablePrograms => _filteredPrograms
      .where((p) => p.latitude != null && p.longitude != null)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("CARTE INTERACTIVE"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppTheme.gold),
            onPressed: _getUserLocation,
            tooltip: "Ma position",
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── OpenStreetMap ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 6,
              onTap: (_, __) => setState(() => _selectedProgram = null),
            ),
            children: [
              // Tuiles OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sociallink.app',
              ),

              // ✅ Markers programmes
              MarkerLayer(
                markers: [
                  // Marker utilisateur
                  if (_userPosition != null)
                    Marker(
                      point: LatLng(
                        _userPosition!.latitude,
                        _userPosition!.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: _UserMarker(),
                    ),

                  // Markers programmes
                  ..._mappablePrograms.map(
                    (program) => Marker(
                      point: LatLng(program.latitude!, program.longitude!),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedProgram = program),
                        child: _ProgramMarker(
                          selected: _selectedProgram?.id == program.id,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Filtres catégories ──
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected ? AppTheme.goldGradient : null,
                        color: selected
                            ? null
                            : AppTheme.bgDark.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : AppTheme.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? AppTheme.bgDark
                              : AppTheme.textWhite,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Loading ──
          if (_loading)
            Container(
              color: AppTheme.bgDark.withValues(alpha: 0.7),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.gold),
              ),
            ),

          // ── Carte programme sélectionné ──
          if (_selectedProgram != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _ProgramMapCard(
                program: _selectedProgram!,
                viewerRole: widget.viewerRole,
                onClose: () => setState(() => _selectedProgram = null),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProgramDetailScreen(
                      program: _selectedProgram!,
                      viewerRole: widget.viewerRole,
                    ),
                  ),
                ),
              ),
            ),

          // ── Compteur ──
          Positioned(
            bottom: _selectedProgram != null ? 190 : 20,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.bgDark.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, color: AppTheme.gold, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "${_mappablePrograms.length} programmes",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bouton ma position ──
          Positioned(
            bottom: _selectedProgram != null ? 190 : 20,
            left: 16,
            child: GestureDetector(
              onTap: _getUserLocation,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  color: AppTheme.bgDark,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets markers ─────────────────────────────────

class _UserMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.blue,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [
        BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 12),
      ],
    ),
    child: const Icon(Icons.person, color: Colors.white, size: 18),
  );
}

class _ProgramMarker extends StatelessWidget {
  final bool selected;
  const _ProgramMarker({this.selected = false});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
      gradient: AppTheme.goldGradient,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: selected ? 3 : 2),
      boxShadow: [
        BoxShadow(
          color: AppTheme.gold.withValues(alpha: selected ? 0.6 : 0.3),
          blurRadius: selected ? 16 : 8,
        ),
      ],
    ),
    padding: EdgeInsets.all(selected ? 6 : 8),
    child: Icon(Icons.place, color: AppTheme.bgDark, size: selected ? 22 : 18),
  );
}

// ── Card programme sélectionné ──────────────────────

class _ProgramMapCard extends StatelessWidget {
  final ProgramModel program;
  final String viewerRole;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const _ProgramMapCard({
    required this.program,
    required this.viewerRole,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volunteer_activism,
              color: AppTheme.bgDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        program.category,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bgDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        program.location,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 12,
                      color: AppTheme.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${program.spotsLeft} places",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.gold,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Voir détails →",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Fermer
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppTheme.textLight,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
