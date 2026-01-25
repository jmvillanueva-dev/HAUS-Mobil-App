import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/landing_page.dart';
import '../../../explore/presentation/pages/explore_tab.dart';
import '../../../listings/presentation/pages/publish_tab.dart';
import '../../../connections/presentation/pages/connections_tab.dart';
import '../../../profile/presentation/pages/profile_tab.dart';
import '../../../matching/presentation/pages/discover_page.dart';
import 'home_tab.dart';

/// Página principal con navegación por tabs estilo "Floating Pill"
class MainPage extends StatefulWidget {
  final UserEntity user;

  const MainPage({
    super.key,
    required this.user,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late UserEntity _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    // El modal de perfil incompleto ya no es necesario
    // porque el onboarding es obligatorio antes de llegar aquí
  }

  List<Widget> get _pages => [
        HomeTab(user: _currentUser),
        const ExploreTab(),
        const PublishTab(),
        const ConnectionsTab(),
        ProfileTab(user: _currentUser),
      ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LandingPage()),
            (route) => false,
          );
        } else if (state is ProfileUpdated) {
          setState(() {
            _currentUser = state.user;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,

        extendBody: true,

        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),

        // Barra de navegación personalizada y flotante
        bottomNavigationBar: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                // AQUÍ ESTÁ EL CAMBIO: Degradado blanco
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.95), // Blanco casi opaco arriba
                    Colors.white
                        .withOpacity(0.85), // Un poco más transparente abajo
                  ],
                ),
                borderRadius: BorderRadius.circular(35),
                // Borde sutil blanco para refinar el acabado
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 0.5,
                ),
                // Sombra ajustada para que resalte el blanco sobre el fondo oscuro de la app
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Sombra más suave
                    blurRadius: 25,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildNavItem(
                        0, Icons.home_rounded, Icons.home_outlined, 'Inicio'),
                    _buildNavItem(1, Icons.search_rounded,
                        Icons.search_outlined, 'Explorar'),
                    _buildCenterNavItem(),
                    _buildNavItem(3, Icons.favorite_rounded,
                        Icons.favorite_outline_rounded, 'Conexiones'),
                    _buildNavItem(4, Icons.person_rounded,
                        Icons.person_outline_rounded, 'Perfil'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSelected ? 8 : 0),
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    )
                  : const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                size: 24,
                // IMPORTANTE: Cambiamos el color de los no seleccionados a gris oscuro
                // para que se vean sobre el fondo blanco
                color: isSelected
                    ? AppTheme.primaryColor
                    : const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),

              // Title with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Qué deseas hacer?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Opción 1: Publicar Propiedad (Turquesa)
              _buildOptionTile(
                icon: Icons.add_home_rounded,
                title: 'Publicar Propiedad',
                subtitle: 'Ofrece una habitación o departamento',
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.6),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 2);
                },
              ),

              const SizedBox(height: 16),

              // Opción 2: Descubrir Roomies (Verde)
              _buildOptionTile(
                icon: Icons.people_rounded,
                title: 'Descubrir Roomies',
                subtitle: 'Encuentra personas compatibles contigo',
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.secondaryColor,
                    AppTheme.secondaryColor.withOpacity(0.6),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiscoverPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (gradient as LinearGradient)
                        .colors
                        .first
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    return GestureDetector(
      onTap: () => _showCreateOptions(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryDark,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 32,
          color: AppTheme.backgroundDark,
        ),
      ),
    );
  }
}
