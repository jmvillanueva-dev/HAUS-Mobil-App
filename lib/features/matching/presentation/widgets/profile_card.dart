import 'dart:ui';
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Imagen de fondo
              _buildProfileImage(),

              // 2. Gradiente optimizado para legibilidad
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.4, 0.7, 1.0],
                    colors: [
                      Colors.black26,
                      Colors.transparent,
                      Colors.black45,
                      Colors.black87,
                    ],
                  ),
                ),
              ),

              // 3. Badge de Compatibilidad (Top Right)
              Positioned(
                top: 20,
                right: 20,
                child: _buildGlassBadge(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on_rounded,
                          color: Color.fromARGB(255, 6, 6, 6), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${candidate.compatibilityScore > 1 ? candidate.compatibilityScore.toInt() : (candidate.compatibilityScore * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Información del perfil (Bottom)
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chips de intereses / Atributos reales
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: candidate
                          .getCharacteristicChips()
                          .map((chip) => _buildInterestChip(chip))
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // Nombre y Verificación
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            candidate.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified_rounded,
                            color: Colors.blueAccent, size: 24),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Profesión / Rol real
                    Row(
                      children: [
                        Icon(
                          candidate.role == 'student'
                              ? Icons.school_outlined
                              : Icons.work_outline,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          candidate.role == 'student'
                              ? 'Estudiante'
                              : 'Profesional',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
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

  // Componente de Cristal (Blur effect)
  Widget _buildGlassBadge({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Componente de Tag / Interés
  Widget _buildInterestChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Image.network(
      candidate.avatarUrl ?? '',
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.2),
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppTheme.surfaceDarkElevated,
        child:
            const Icon(Icons.person_rounded, size: 80, color: Colors.white24),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppTheme.surfaceDark,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}
