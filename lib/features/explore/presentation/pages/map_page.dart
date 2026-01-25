import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../listings/domain/entities/listing_entity.dart';
import '../../../listings/presentation/bloc/listing_bloc.dart';
import '../../../listings/presentation/bloc/listing_event.dart';
import '../../../listings/presentation/bloc/listing_state.dart';
import '../../../matching/domain/repositories/matching_repository.dart';
import '../../../matching/domain/entities/match_entity.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ListingBloc>(),
      child: const _MapPageContent(),
    );
  }
}

class _MapPageContent extends StatefulWidget {
  const _MapPageContent();

  @override
  State<_MapPageContent> createState() => _MapPageContentState();
}

class _MapPageContentState extends State<_MapPageContent> {
  final MapController _mapController = MapController();
  final MatchingRepository _matchingRepository =
      GetIt.instance<MatchingRepository>();

  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _error;

  List<ListingEntity> _allListings = []; // Store all listings
  List<ListingEntity> _displayedListings = []; // Listings currently shown
  List<Match> _matches = [];

  String _activeFilter = 'none'; // 'none', 'all', 'matches'

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Load matches in background
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final result = await _matchingRepository.getMatches();
    result.fold(
      (failure) => print('Error loading matches: ${failure.message}'),
      (matches) {
        if (mounted) {
          setState(() {
            _matches = matches;
          });
        }
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Los permisos de ubicación fueron denegados.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Los permisos de ubicación están denegados permanentemente.');
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(_currentPosition!, 15);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _currentPosition = const LatLng(-0.180653, -78.467834);
        });
      }
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilter == filter) {
        _activeFilter = 'none';
        _displayedListings = [];
      } else {
        _activeFilter = filter;
        if (filter == 'all') {
          context.read<ListingBloc>().add(LoadListingsEvent());
        } else if (filter == 'matches') {
          // If we don't have listings yet, load them first
          if (_allListings.isEmpty) {
            context.read<ListingBloc>().add(LoadListingsEvent());
          } else {
            _filterMatches();
          }
        }
      }
    });
  }

  void _filterMatches() {
    final matchedUserIds = _matches
        .map((m) => m.otherUser?.userId)
        .where((id) => id != null)
        .toSet();

    setState(() {
      _displayedListings = _allListings.where((listing) {
        return matchedUserIds.contains(listing.userId);
      }).toList();

      _fitBoundsToListings(_displayedListings);
    });

    if (_displayedListings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se encontraron publicaciones de tus matches')),
      );
    }
  }

  void _showListingDetails(ListingEntity listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  listing.imageUrls.first,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              listing.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${listing.price.toStringAsFixed(0)} / mes',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: AppTheme.textSecondaryDark, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    listing.address,
                    style: const TextStyle(
                        color: AppTheme.textSecondaryDark, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navegar a detalles completos
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ver Detalles',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fitBoundsToListings(List<ListingEntity> listings) {
    if (listings.isEmpty) return;

    final points = listings
        .where((l) => l.latitude != null && l.longitude != null)
        .map((l) => LatLng(l.latitude!, l.longitude!))
        .toList();

    if (points.isEmpty) return;

    // Include current position if available to keep context
    if (_currentPosition != null) {
      points.add(_currentPosition!);
    }

    final bounds = LatLngBounds.fromPoints(points);

    // Fit camera to bounds with padding
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(80), // Padding to avoid UI overlap
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocListener<ListingBloc, ListingState>(
        listener: (context, state) {
          if (state is ListingsLoaded) {
            setState(() {
              _allListings = state.listings;
              // Apply current filter
              if (_activeFilter == 'all') {
                _displayedListings = _allListings;
                _fitBoundsToListings(_displayedListings);
              } else if (_activeFilter == 'matches') {
                _filterMatches();
              }
            });
          } else if (state is ListingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Stack(
          children: [
            // Mapa
            if (_currentPosition != null)
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition!,
                  initialZoom: 15.0,
                  backgroundColor: AppTheme.backgroundDark,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.haus_app',
                    tileBuilder: (context, widget, tile) {
                      return widget;
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      // Marcador del usuario
                      Marker(
                        point: _currentPosition!,
                        width: 60,
                        height: 60,
                        child: _buildUserMarker(),
                      ),
                      // Marcadores de listings
                      ..._displayedListings
                          .where(
                              (l) => l.latitude != null && l.longitude != null)
                          .map((listing) => Marker(
                                point: LatLng(
                                    listing.latitude!, listing.longitude!),
                                width: 60,
                                height: 60,
                                child: GestureDetector(
                                  onTap: () => _showListingDetails(listing),
                                  child: _buildListingMarker(),
                                ),
                              )),
                    ],
                  ),
                ],
              ),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),

            if (_error != null && !_isLoading)
              Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Header con Filtros
            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Botón atrás
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Filtros (Scroll horizontal)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  'Todos',
                                  Icons.tune,
                                  onTap: () => _toggleFilter('all'),
                                  isSelected: _activeFilter == 'all',
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Matches',
                                  Icons.favorite_rounded,
                                  onTap: () => _toggleFilter('matches'),
                                  isSelected: _activeFilter == 'matches',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Botón para centrar ubicación
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton(
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF40E0D0), // Turquesa
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF40E0D0).withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildListingMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.successColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.successColor.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon,
      {VoidCallback? onTap, bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[700]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
