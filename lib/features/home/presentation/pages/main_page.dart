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
import 'home_tab.dart';
import '../../../../core/widgets/profile_incomplete_modal.dart';

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

    // Mostrar modal si perfil incompleto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_currentUser.isProfileComplete) {
        _showProfileIncompleteModal();
      }
    });
  }

  void _showProfileIncompleteModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileIncompleteModal(
        user: _currentUser,
        onComplete: () {
          Navigator.pop(context);
          setState(() => _currentIndex = 4); // Ir a tab de perfil
        },
        onSkip: () => Navigator.pop(context),
      ),
    );
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
                    Colors.white.withOpacity(0.85), // Un poco más transparente abajo
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
                    _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Inicio'),
                    _buildNavItem(1, Icons.search_rounded, Icons.search_outlined, 'Explorar'),
                    _buildCenterNavItem(),
                    _buildNavItem(3, Icons.favorite_rounded, Icons.favorite_outline_rounded, 'Conexiones'),
                    _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Perfil'),
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

  Widget _buildCenterNavItem() {
    final isSelected = _currentIndex == 2;
    // Reduje ligeramente el tamaño (de 56 a 50) para que encaje mejor en la barra de 70px
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 50, 
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [AppTheme.primaryColor, AppTheme.primaryDark]
                : [
                    AppTheme.primaryColor.withOpacity(0.9),
                    AppTheme.primaryDark.withOpacity(0.9)
                  ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.add_rounded,
          size: 28,
          color: AppTheme.backgroundDark,
        ),
      ),
    );
  }
}