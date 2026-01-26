import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../locations/presentation/pages/my_locations_page.dart';
import '../../../matching/presentation/pages/preferences_page.dart';
import '../../../financial/presentation/pages/haus_business_page.dart';
import '../../../subscription/presentation/pages/subscription_page.dart';
import 'edit_profile_page.dart';

/// Tab de Perfil - Diseño limpio y moderno
class ProfileTab extends StatelessWidget {
  final UserEntity user;

  const ProfileTab({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Title
            const Text(
              'Perfil',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 24),

            // DIV 1: Perfil Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar Grande
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                      image:
                          user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(user.avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                        ? Center(
                            child: Text(
                              _getInitials(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryDark,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user.email.split('@')[0]}', // Simular username
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón Editar Cuadrado
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditProfilePage(user: user),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Editar Perfil',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DIV 2: Lista de Opciones
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.business_center_rounded,
                    label: 'Haus Business',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HausBusinessPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.star_border_rounded,
                    label: 'Mi Plan',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.subscriptionTier.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.favorite_border_rounded,
                    label: 'Mis Favoritos',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.tune_rounded,
                    label: 'Mis Preferencias',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PreferencesPage(userId: user.id),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Mis Ubicaciones',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MyLocationsPage(user: user),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.verified_outlined,
                    label: 'Verificación',
                    trailing: _buildVerificationBadge(),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notificaciones',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.security_outlined,
                    label: 'Privacidad y seguridad',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Ayuda y soporte',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DIV 3: Cerrar Sesión
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: _buildMenuItem(
                icon: Icons.logout_rounded,
                label: 'Cerrar sesión',
                isDestructive: true,
                onTap: () {
                  context.read<AuthBloc>().add(const SignOutRequested());
                },
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppTheme.errorColor.withValues(alpha: 0.1)
                  : AppTheme.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? AppTheme.errorColor
                  : AppTheme.textPrimaryDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? AppTheme.errorColor
                    : AppTheme.textPrimaryDark,
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: 12),
          ],
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.textTertiaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge() {
    final color = AppTheme.getVerificationColor(user.verificationStatus.name);

    // Solo mostrar badge si está verificado o en proceso
    if (user.verificationStatus.name == 'unverified') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        user.verificationStatus.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _getInitials() {
    String initials = '';
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      initials += user.firstName![0].toUpperCase();
    }
    if (user.lastName != null && user.lastName!.isNotEmpty) {
      initials += user.lastName![0].toUpperCase();
    }
    if (initials.isEmpty) {
      initials = user.email.substring(0, 2).toUpperCase();
    }
    return initials;
  }
}
