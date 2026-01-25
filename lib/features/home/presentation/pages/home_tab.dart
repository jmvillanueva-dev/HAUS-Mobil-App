import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
// Imports de Listings (Para la lógica real)
import '../../../listings/presentation/bloc/listing_bloc.dart';
import '../../../listings/presentation/bloc/listing_event.dart';
import '../../../listings/presentation/bloc/listing_state.dart';
import '../../../listings/domain/entities/listing_entity.dart';
import '../../../listings/presentation/pages/listing_detail_page.dart';

/// Tab de Inicio - Feed de habitaciones y roommates recomendados
class HomeTab extends StatelessWidget {
  final UserEntity user;

  const HomeTab({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // Inyectamos el Bloc y cargamos las publicaciones inmediatamente
    return BlocProvider(
      create: (_) => GetIt.instance<ListingBloc>()..add(LoadListingsEvent()),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(
          // RefreshIndicator permite recargar arrastrando hacia abajo
          child: BlocBuilder<ListingBloc, ListingState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ListingBloc>().add(LoadListingsEvent());
                },
                color: AppTheme.primaryColor,
                child: CustomScrollView(
                  slivers: [
                    // 1. Header con ubicación
                    SliverToBoxAdapter(
                      child: _buildHeader(context),
                    ),

                    // 2. Barra de búsqueda (Restaurada)
                    SliverToBoxAdapter(
                      child: _buildSearchBar(),
                    ),

                    // 3. Sección: Roommates recomendados (Restaurada - Datos Mock)
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('Roommates recomendados',
                          onSeeAll: () {}),
                    ),
                    SliverToBoxAdapter(
                      child: _buildRecommendedRoommates(),
                    ),

                    // 4. Sección: Habitaciones (CON DATOS REALES DE SUPABASE)
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('Habitaciones recientes',
                          onSeeAll: () {}),
                    ),
                    SliverToBoxAdapter(
                      child: _buildRealListingsList(state),
                    ),

                    // 5. Sección: Tus matches (Restaurada - Datos Mock)
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('Tus matches', onSeeAll: () {}),
                    ),
                    SliverToBoxAdapter(
                      child: _buildMatches(),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE LA UI ORIGINAL RESTAURADOS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar de usuario
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
              image: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(user.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: AppTheme.surfaceDark,
            ),
            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                ? Center(
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                : null,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${user.firstName ?? user.displayName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Quito, Ecuador',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notification bell
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.textPrimaryDark,
                    size: 22,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search_rounded,
                    color: AppTheme.textSecondaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Buscar roommate o habitación...',
                      style: TextStyle(
                        color: AppTheme.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: AppTheme.textPrimaryDark,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryDark,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- SECCIÓN ROOMMATES (ORIGINAL - DATOS MOCK) ---
  Widget _buildRecommendedRoommates() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) => _buildRoommateCard(index),
      ),
    );
  }

  Widget _buildRoommateCard(int index) {
    final names = ['María', 'Carlos', 'Ana', 'Diego', 'Laura'];
    final ages = [24, 26, 22, 28, 23];
    final roles = [
      'Estudiante',
      'Trabajador',
      'Estudiante',
      'Trabajador',
      'Estudiante'
    ];

    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.3),
                        AppTheme.primaryDark.withOpacity(0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      names[index][0],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${names[index]}, ${ages[index]}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roles[index],
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ver perfil',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SECCIÓN PUBLICACIONES REALES (NUEVA LÓGICA) ---
  Widget _buildRealListingsList(ListingState state) {
    if (state is ListingLoading) {
      return const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator()));
    } else if (state is ListingsLoaded) {
      if (state.listings.isEmpty) {
        return const SizedBox(
            height: 100,
            child: Center(
                child: Text("No hay habitaciones recientes",
                    style: TextStyle(color: Colors.white54))));
      }
      return SizedBox(
        height: 280, // Altura para el diseño "grande"
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: state.listings.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return _buildListingCard(context, state.listings[index]);
          },
        ),
      );
    } else if (state is ListingError) {
      return Center(
          child:
              Text(state.message, style: const TextStyle(color: Colors.red)));
    }
    return const SizedBox.shrink();
  }

  // ESTA ES LA CARD QUE TE GUSTÓ (DISEÑO MEJORADO)
  Widget _buildListingCard(BuildContext context, ListingEntity listing) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ListingDetailPage(listing: listing)),
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: listing.imageUrls.isNotEmpty
                    ? Image.network(
                        listing.imageUrls.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white54),
                        ),
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Center(
                            child: Icon(Icons.home,
                                color: Colors.white54, size: 40)),
                      ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          listing.housingType,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12, color: AppTheme.textSecondaryDark),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${listing.neighborhood}, ${listing.city}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${listing.price.toStringAsFixed(0)} / mes',
                    style: const TextStyle(
                      fontSize: 14,
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

  // --- SECCIÓN MATCHES (ORIGINAL - DATOS MOCK) ---
  Widget _buildMatches() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          // Avatars stack
          SizedBox(
            width: 80,
            child: Stack(
              children: List.generate(3, (index) {
                return Positioned(
                  left: index * 20.0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          AppTheme.primaryColor.withOpacity(0.2 + index * 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surfaceDark, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        ['A', 'B', 'C'][index],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tienes 3 matches nuevos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                Text(
                  'Empieza a chatear',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.textSecondaryDark,
          ),
        ],
      ),
    );
  }
}
