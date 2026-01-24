import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/user_location_entity.dart';
import '../bloc/locations_bloc.dart';
import 'add_location_page.dart';
import 'edit_location_page.dart';

class MyLocationsPage extends StatelessWidget {
  final UserEntity user;

  const MyLocationsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<LocationsBloc>()..add(LoadMyLocations(user.id)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          elevation: 0,
          toolbarHeight: 70, // Added space to header
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimaryDark,
                size: 18,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Mis Ubicaciones',
            style: TextStyle(
              color: AppTheme.textPrimaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return BlocBuilder<LocationsBloc, LocationsState>(
              builder: (context, state) {
                if (state is LocationsLoaded && state.locations.length >= 3) {
                  return const SizedBox.shrink();
                }
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<LocationsBloc>(),
                            child: AddLocationPage(userId: user.id),
                          ),
                        ),
                      );
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add_location_alt_rounded,
                        color: Colors.white),
                  ),
                );
              },
            );
          },
        ),
        body: BlocBuilder<LocationsBloc, LocationsState>(
          builder: (context, state) {
            if (state is LocationsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              );
            } else if (state is LocationsLoaded) {
              if (state.locations.isEmpty) {
                return _buildEmptyState();
              }
              return _buildLocationsList(context, state.locations);
            } else if (state is LocationsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 48, color: AppTheme.errorColor),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.map_outlined,
              size: 64,
              color: AppTheme.textSecondaryDark.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes ubicaciones guardadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tus lugares frecuentes para\nfacilitar la búsqueda de roomies.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList(
      BuildContext context, List<UserLocationEntity> locations) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: locations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final location = locations[index];
        return _buildLocationItem(context, location);
      },
    );
  }

  Widget _buildLocationItem(BuildContext context, UserLocationEntity location) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: location.isPrimary
            ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<LocationsBloc>(),
                  child: EditLocationPage(
                    location: location,
                    userId: user.id,
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.2),
                        AppTheme.primaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    location.label.icon,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            location.label.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryDark,
                            ),
                          ),
                          if (location.isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.primaryDark
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Principal',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        location.formattedAddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryDark,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location.city != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_city_rounded,
                              size: 12,
                              color: AppTheme.textTertiaryDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location.city!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiaryDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppTheme.textTertiaryDark.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
