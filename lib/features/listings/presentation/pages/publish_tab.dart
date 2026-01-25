import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart'; // Para sl()
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart'; // Para verificar estados del usuario
import '../bloc/listing_bloc.dart';
import 'create_listing_page.dart';
import 'my_listings_page.dart';

/// Tab de Publicar - Crear publicación de habitación
class PublishTab extends StatelessWidget {
  const PublishTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Publicar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comparte tu habitación disponible',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryDark,
              ),
            ),

            const Spacer(),

            // Placeholder illustration
            Center(
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.2),
                          AppTheme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.add_home_rounded,
                      size: 64,
                      color: AppTheme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '¿Tienes un espacio disponible?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Publica tu habitación y encuentra al roomie ideal.\nIncluye fotos, precio, servicios y reglas.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryDark,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Features
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeature(Icons.photo_camera_rounded, 'Fotos'),
                      const SizedBox(width: 24),
                      _buildFeature(Icons.attach_money_rounded, 'Precio'),
                      const SizedBox(width: 24),
                      _buildFeature(Icons.rule_rounded, 'Reglas'),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Create button
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  _navigateToCreateListing(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.add_rounded,
                  color: AppTheme.backgroundDark,
                ),
                label: const Text(
                  'Crear publicación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.backgroundDark,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Edit button (My Listings)
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor),
                color: AppTheme.surfaceDark,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  _navigateToMyListings(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: AppTheme.primaryColor,
                ),
                label: const Text(
                  'Mis publicaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateListing(BuildContext context) {
    // 1. Obtener el estado actual de la autenticación
    final authState = context.read<AuthBloc>().state;
    String? userId;

    // 2. Extraer el ID según el tipo de estado
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    } else if (authState is ProfileUpdated) {
      userId = authState.user.id;
    }

    // 3. Navegar si tenemos usuario, sino mostrar error
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<ListingBloc>(), // Inyección del Bloc
            child: CreateListingPage(userId: userId!),
          ),
        ),
      );
    } else {
      _showAuthError(context);
    }
  }

  void _navigateToMyListings(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? userId;

    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    } else if (authState is ProfileUpdated) {
      userId = authState.user.id;
    }

    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyListingsPage(
              userId:
                  userId!), // MyListingsPage injects its own bloc via sl() inside
        ),
      );
    } else {
      _showAuthError(context);
    }
  }

  void _showAuthError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error: No se pudo identificar al usuario actual.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderDark),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryDark,
          ),
        ),
      ],
    );
  }
}
