import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/user_location_entity.dart';
import '../bloc/locations_bloc.dart';

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimaryDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Mis Ubicaciones',
            style: TextStyle(
              color: AppTheme.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<LocationsBloc, LocationsState>(
          builder: (context, state) {
            if (state is LocationsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LocationsLoaded) {
              if (state.locations.isEmpty) {
                return _buildEmptyState();
              }
              return _buildLocationsList(state.locations);
            } else if (state is LocationsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppTheme.errorColor),
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
          Icon(
            Icons.location_off_rounded,
            size: 64,
            color: AppTheme.textSecondaryDark.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes ubicaciones guardadas',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList(List<UserLocationEntity> locations) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: locations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final location = locations[index];
        return _buildLocationItem(location);
      },
    );
  }

  Widget _buildLocationItem(UserLocationEntity location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              location.isPrimary ? AppTheme.primaryColor : AppTheme.borderDark,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Principal',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location.formattedAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (location.city != null)
                  Text(
                    location.city!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiaryDark,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
