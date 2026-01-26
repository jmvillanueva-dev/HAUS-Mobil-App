import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/match_entity.dart';

class RoomieProfilePage extends StatefulWidget {
  final MatchCandidate candidate;

  const RoomieProfilePage({super.key, required this.candidate});

  @override
  State<RoomieProfilePage> createState() => _RoomieProfilePageState();
}

class _RoomieProfilePageState extends State<RoomieProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 150 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 150 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppTheme.backgroundDark,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: _isScrolled
                  ? Text(
                      widget.candidate.firstName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover Image (Random Architecture)
                    Image.network(
                      'https://images.unsplash.com/photo-1600607686527-6fb886090705?q=80&w=2000&auto=format&fit=crop',
                      fit: BoxFit.cover,
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.backgroundDark.withOpacity(0.8),
                            AppTheme.backgroundDark,
                          ],
                          stops: const [0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                    // Profile Info
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Avatar with Border
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.backgroundDark, width: 4),
                              image: widget.candidate.avatarUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          widget.candidate.avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: AppTheme.surfaceDark,
                            ),
                            child: widget.candidate.avatarUrl == null
                                ? Center(
                                    child: Text(
                                      widget.candidate.firstName[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.candidate.firstName} ${widget.candidate.lastName}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _translateRole(widget.candidate.role),
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.star_rounded,
                                        color: Colors.amber, size: 16),
                                    Text(
                                      ' ${(widget.candidate.compatibilityScore).toInt()}% Compatible',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  tabs: const [
                    Tab(text: 'Sobre mí'),
                    Tab(text: 'Estilo de Vida'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(),
            _buildLifestyleTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          border: Border(
              top: BorderSide(color: AppTheme.borderDark.withOpacity(0.5))),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar chat o conexión
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Conectar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.candidate.bio != null &&
              widget.candidate.bio!.isNotEmpty) ...[
            const Text(
              'Biografía',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.candidate.bio!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Budget
          const Text(
            'Presupuesto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_money_rounded,
                    color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rango Mensual',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.candidate.budgetMin?.toInt() ?? 0} - \$${widget.candidate.budgetMax?.toInt() ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Interests
          if (widget.candidate.interests != null &&
              widget.candidate.interests!.isNotEmpty) ...[
            const Text(
              'Intereses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.candidate.interests!.map((interest) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _translateInterest(interest),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLifestyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.smoking_rooms_rounded, 'Fumador',
              widget.candidate.isSmoker == true ? 'Sí' : 'No'),
          _buildInfoRow(
              Icons.pets_rounded,
              'Mascotas',
              widget.candidate.hasPets == true
                  ? 'Tiene mascotas'
                  : 'Sin mascotas'),
          _buildInfoRow(
              Icons.fitness_center_rounded,
              'Ejercicio',
              widget.candidate.exercises == true
                  ? 'Frecuentemente'
                  : 'Ocasional'),
          _buildInfoRow(
              Icons.nightlife_rounded,
              'Fiestas',
              widget.candidate.likesParties == true
                  ? 'Le gustan'
                  : 'Prefiere tranquilidad'),
          _buildInfoRow(
              Icons.work_rounded,
              'Trabajo',
              widget.candidate.worksFromHome == true
                  ? 'Home Office'
                  : 'Presencial'),
          _buildInfoRow(Icons.volume_up_rounded, 'Ruido',
              _getNoiseLevelText(widget.candidate.noiseLevel)),
          _buildInfoRow(Icons.schedule_rounded, 'Horario',
              _getSleepScheduleText(widget.candidate.sleepSchedule)),
        ],
      ),
    );
  }

  String _translateInterest(String interest) {
    final map = {
      'gaming': 'Videojuegos',
      'music': 'Música',
      'sports': 'Deportes',
      'reading': 'Lectura',
      'cooking': 'Cocina',
      'travel': 'Viajes',
      'movies': 'Cine',
      'art': 'Arte',
      'photography': 'Fotografía',
      'technology': 'Tecnología',
      'dancing': 'Baile',
      'hiking': 'Senderismo',
    };
    return map[interest.toLowerCase()] ?? interest;
  }

  String _translateRole(String? role) {
    if (role == null) return 'Roomie';
    switch (role.toLowerCase()) {
      case 'student':
        return 'Estudiante';
      case 'professional':
        return 'Profesional';
      case 'worker':
        return 'Trabajador';
      case 'digital nomad':
        return 'Nómada Digital';
      default:
        return role;
    }
  }

  String _getNoiseLevelText(String? level) {
    switch (level) {
      case 'quiet':
        return 'Silencioso';
      case 'moderate':
        return 'Moderado';
      case 'social':
        return 'Social'; // Es igual en español
      case 'loud':
        return 'Ruidoso';
      default:
        return 'No especificado';
    }
  }

  String _getSleepScheduleText(String? schedule) {
    switch (schedule) {
      case 'early_bird':
        return 'Madrugador';
      case 'night_owl':
        return 'Nocturno';
      case 'flexible':
        return 'Flexible';
      default:
        return 'Flexible';
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundDark,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
