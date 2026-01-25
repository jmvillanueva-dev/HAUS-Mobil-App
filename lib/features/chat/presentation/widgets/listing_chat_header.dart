import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget que muestra un resumen del listing en la parte superior del chat
/// Similar a un card compacto con imagen, título y precio
class ListingChatHeader extends StatelessWidget {
  final String? listingTitle;
  final String? listingImageUrl;
  final double? listingPrice;
  final VoidCallback? onTap;

  const ListingChatHeader({
    super.key,
    this.listingTitle,
    this.listingImageUrl,
    this.listingPrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // No mostrar si no hay datos del listing
    if (listingTitle == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen del listing
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 56,
                height: 56,
                color: AppTheme.surfaceDarkElevated,
                child: listingImageUrl != null
                    ? Image.network(
                        listingImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),

            // Información del listing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listingTitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (listingPrice != null)
                    Text(
                      '\$${listingPrice!.toStringAsFixed(0)}/mes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                ],
              ),
            ),

            // Icono de navegación
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondaryDark,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.home_rounded,
        color: AppTheme.textTertiaryDark,
        size: 24,
      ),
    );
  }
}
