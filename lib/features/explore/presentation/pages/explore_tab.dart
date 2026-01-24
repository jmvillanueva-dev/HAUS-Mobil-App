import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../listings/presentation/bloc/listing_bloc.dart';
import '../../../listings/presentation/bloc/listing_event.dart';
import '../../../listings/presentation/bloc/listing_state.dart';
import '../../../listings/domain/entities/listing_entity.dart';
import '../../../listings/presentation/pages/listing_detail_page.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ListingBloc>()..add(LoadListingsEvent()),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header y Buscador
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explorar',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar por zona, precio...',
                        hintStyle: TextStyle(color: AppTheme.textSecondaryDark),
                        prefixIcon: Icon(Icons.search, color: AppTheme.textSecondaryDark),
                        filled: true,
                        fillColor: AppTheme.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // --- FILTROS (RESTAURADOS) ---
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Precio', Icons.keyboard_arrow_down),
                          const SizedBox(width: 8),
                          _buildFilterChip('Ubicación', Icons.keyboard_arrow_down),
                          const SizedBox(width: 8),
                          _buildFilterChip('Tipo', Icons.keyboard_arrow_down),
                          const SizedBox(width: 8),
                          _buildFilterChip('Servicios', Icons.tune),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista Vertical
              Expanded(
                child: BlocBuilder<ListingBloc, ListingState>(
                  builder: (context, state) {
                    if (state is ListingLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ListingsLoaded) {
                      if (state.listings.isEmpty) {
                        return const Center(child: Text("No se encontraron resultados", style: TextStyle(color: Colors.white)));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: state.listings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return _buildExploreCard(context, state.listings[index]);
                        },
                      );
                    } else if (state is ListingError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Icon(icon, color: AppTheme.textSecondaryDark, size: 16),
        ],
      ),
    );
  }

  Widget _buildExploreCard(BuildContext context, ListingEntity listing) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListingDetailPage(listing: listing)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen Grande
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: listing.imageUrls.isNotEmpty
                    ? Image.network(
                        listing.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                             Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.white54)),
                      )
                    : Container(color: Colors.grey[800], child: const Icon(Icons.home, color: Colors.white54, size: 50)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${listing.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppTheme.textSecondaryDark),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.address,
                          style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Amenities Chips (Mostrar solo los primeros 3)
                  Wrap(
                    spacing: 8,
                    children: listing.amenities.take(3).map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}