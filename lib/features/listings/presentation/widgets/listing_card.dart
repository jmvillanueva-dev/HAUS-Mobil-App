import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/listing_entity.dart';
import '../pages/listing_detail_page.dart';

class ListingCard extends StatelessWidget {
  final ListingEntity listing;

  const ListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ListingDetailPage(listing: listing)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen Principal (Sin overlays, estilo Home ampliado)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: listing.imageUrls.isNotEmpty
                        ? Image.network(
                            listing.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.broken_image,
                                    color: Colors.white54)),
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.home,
                                color: Colors.white54, size: 50)),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: listing.isAvailable
                              ? Colors.green.withValues(alpha: 0.9)
                              : Colors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          listing.isAvailable ? 'Disponible' : 'No disponible',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ],
              ),
            ),

            // Información
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Tipo de Vivienda
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      listing.housingType,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Título
                  Text(
                    listing.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Ubicación
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${listing.neighborhood}, ${listing.city}', // Usando formato del Home
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Amenities (Iconos) - Solicitado explícitamente conservar
                  if (listing.amenities.isNotEmpty) ...[
                    Row(
                      children: listing.amenities.take(5).map((amenity) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Tooltip(
                            message: amenity,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getAmenityIcon(amenity),
                                size: 16, // Iconos pequeños como pidió
                                color: AppTheme.textSecondaryDark,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Precio
                  Text(
                    '\$${listing.price.toStringAsFixed(0)} / mes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'cocina':
        return Icons.kitchen;
      case 'lavadora':
        return Icons.local_laundry_service;
      case 'tv':
        return Icons.tv;
      case 'aire acondicionado':
        return Icons.ac_unit;
      case 'baño privado':
        return Icons.bathtub;
      case 'gym':
      case 'gimnasio':
        return Icons.fitness_center;
      case 'pet friendly':
        return Icons.pets;
      case 'estacionamiento':
        return Icons.local_parking;
      default:
        return Icons.check_circle_outline;
    }
  }
}
