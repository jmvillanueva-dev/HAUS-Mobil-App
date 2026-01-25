import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/match_entity.dart';

class ProfileCard extends StatelessWidget {
  final MatchCandidate candidate;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.candidate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: AppTheme.surfaceDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo
              _buildProfileImage(),

              // Gradiente inferior para legibilidad
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 300,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Badge de Distancia (Top Left)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '500 m',
                        style: TextStyle(
                          color: AppTheme.backgroundDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.location_on_rounded,
                          color: AppTheme.primaryColor, size: 14),
                    ],
                  ),
                ),
              ),

              // Iconos flotantes (Top Right)
              Positioned(
                top: 20,
                right: 20,
                child: Column(
                  children: [
                    _buildFloatingIcon(
                        Icons.favorite_rounded, Colors.redAccent),
                    const SizedBox(height: 8),
                    _buildFloatingIcon(
                        Icons.videogame_asset_rounded, Colors.orangeAccent),
                    const SizedBox(height: 8),
                    _buildFloatingIcon(
                        Icons.music_note_rounded, Colors.blueAccent),
                    const SizedBox(height: 8),
                    _buildFloatingIcon(
                        Icons.pets_rounded, AppTheme.secondaryColor),
                  ],
                ),
              ),

              // Información del perfil (Bottom)
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge pequeño arriba del nombre
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Hate to chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chat_bubble_rounded,
                              color: Colors.white.withOpacity(0.8), size: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nombre y Verified Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ],
                    ),

                    // Rol / Ocupación
                    Text(
                      candidate.role == 'student' ? 'Estudiante' : 'Trabajador',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildProfileImage() {
    if (candidate.avatarUrl != null && candidate.avatarUrl!.isNotEmpty) {
      return Image.network(
        candidate.avatarUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppTheme.primaryColor,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.surfaceDarkElevated,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 80,
          color: AppTheme.textSecondaryDark.withOpacity(0.5),
        ),
      ),
    );
  }
}
