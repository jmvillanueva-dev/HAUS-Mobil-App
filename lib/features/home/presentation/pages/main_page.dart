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

/// Página principal con navegación por tabs
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
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            border: Border(
              top: BorderSide(
                color: AppTheme.borderDark,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                      0, Icons.home_rounded, Icons.home_outlined, 'Inicio'),
                  _buildNavItem(1, Icons.search_rounded, Icons.search_outlined,
                      'Explorar'),
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
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              size: 24,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryDark,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [AppTheme.primaryColor, AppTheme.primaryDark]
                : [
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                    AppTheme.primaryDark.withValues(alpha: 0.8)
                  ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
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
