import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Tab de Explorar - Búsqueda con filtros
class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

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
              'Explorar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Encuentra tu roomie ideal o la habitación perfecta',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 24),

            // Search bar
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search_rounded,
                    color: AppTheme.textSecondaryDark,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar por zona, precio, tipo...',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondaryDark,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Precio', Icons.attach_money_rounded),
                  _buildFilterChip('Zona', Icons.location_on_outlined),
                  _buildFilterChip('Tipo', Icons.bed_outlined),
                  _buildFilterChip('Match', Icons.favorite_outline_rounded),
                ],
              ),
            ),

            const Spacer(),

            // Placeholder
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      size: 48,
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Próximamente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los filtros avanzados estarán disponibles pronto',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textTertiaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondaryDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimaryDark,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 16, color: AppTheme.textSecondaryDark),
        ],
      ),
    );
  }
}
