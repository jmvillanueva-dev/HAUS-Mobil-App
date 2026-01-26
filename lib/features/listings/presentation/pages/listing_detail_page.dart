import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/listing_entity.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../requests/presentation/bloc/request_bloc.dart';
import '../../../requests/presentation/bloc/request_event.dart';
import '../../../requests/presentation/bloc/request_state.dart';

class ListingDetailPage extends StatelessWidget {
  final ListingEntity listing;

  const ListingDetailPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<RequestBloc>()
        ..add(CheckRequestStatus(listingId: listing.id!)),
      child: _ListingDetailView(listing: listing),
    );
  }
}

class _ListingDetailView extends StatefulWidget {
  final ListingEntity listing;

  const _ListingDetailView({required this.listing});

  @override
  State<_ListingDetailView> createState() => _ListingDetailViewState();
}

class _ListingDetailViewState extends State<_ListingDetailView> {
  bool _isContactingHost = false;

  ListingEntity get listing => widget.listing;

  /// Verifica si el usuario actual es el dueño del listing
  bool get _isOwnListing {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return currentUserId != null && currentUserId == listing.userId;
  }

  Future<void> _contactHost() async {
    if (_isContactingHost) return;

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para contactar')),
      );
      return;
    }

    // No permitir contactarse a sí mismo
    if (_isOwnListing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes contactarte a ti mismo')),
      );
      return;
    }

    setState(() => _isContactingHost = true);

    try {
      final chatBloc = GetIt.I<ChatBloc>();

      // Crear o obtener conversación existente
      chatBloc.add(CreateConversation(
        listingId: listing.id!,
        hostId: listing.userId,
      ));

      // Escuchar el resultado
      await for (final state in chatBloc.stream) {
        if (state is ConversationCreated) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  conversationId: state.conversation.id,
                  listingId: listing.id,
                  listingTitle: listing.title,
                  listingImageUrl: listing.imageUrls.isNotEmpty
                      ? listing.imageUrls.first
                      : null,
                  listingPrice: listing.price,
                  otherUserName: state.conversation.otherUserName,
                ),
              ),
            );
          }
          break;
        } else if (state is ConversationCreateError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isContactingHost = false);
      }
    }
  }

  void _openFullScreenMap() {
    if (listing.latitude != null && listing.longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenMapView(
            latitude: listing.latitude!,
            longitude: listing.longitude!,
            address: listing.address,
          ),
        ),
      );
    }
  }

  void _sendRequest() {
    if (_isOwnListing) return;

    // 1. Guardamos una referencia al Bloc ACTUAL antes de abrir el diálogo
    final requestBloc = context.read<RequestBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        // <--- AQUÍ ESTÁ EL TRUCO
        value:
            requestBloc, // Usamos la instancia existente, no creamos una nueva
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Enviar Solicitud',
              style: AppTheme.darkTheme.textTheme.headlineSmall),
          content: Text(
            '¿Quieres enviar una solicitud de interés al anfitrión?',
            style: AppTheme.darkTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Ahora sí podemos usar el bloc de forma segura
                requestBloc.add(SendRequest(
                  listingId: listing.id!,
                  hostId: listing.userId,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
              ),
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<RequestBloc, RequestState>(
      listener: (context, state) {
        if (state is RequestOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else if (state is RequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: CustomScrollView(
          slivers: [
            // 1. App Bar con Imagen Principal
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: AppTheme.backgroundDark,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.white,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    listing.imageUrls.isNotEmpty
                        ? Image.network(
                            listing.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: AppTheme.surfaceDark),
                          )
                        : Container(
                            color: AppTheme.surfaceDark,
                            child: Icon(Icons.home,
                                size: 64, color: AppTheme.textSecondaryDark),
                          ),
                    // Gradiente para mejorar legibilidad si hubiera texto sobre la imagen
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Contenido
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                transform:
                    Matrix4.translationValues(0, -20, 0), // Slight overlap
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Housing Type & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      AppTheme.primaryColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              listing.housingType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            '\$${listing.price.toStringAsFixed(0)}',
                            style: textTheme.headlineMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        listing.title,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 20, color: AppTheme.textSecondaryDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${listing.neighborhood}, ${listing.city}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  listing.address,
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: AppTheme.dividerDark),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Descripción',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        listing.description,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: AppTheme.textSecondaryDark,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: AppTheme.dividerDark),
                      const SizedBox(height: 24),

                      // Servicios (Amenities)
                      if (listing.amenities.isNotEmpty) ...[
                        Text(
                          'Lo que ofrece este lugar',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: listing.amenities.map((amenity) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderDark),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded,
                                      size: 16, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    amenity,
                                    style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppTheme.dividerDark),
                        const SizedBox(height: 24),
                      ],

                      // Reglas de la casa
                      if (listing.houseRules.isNotEmpty) ...[
                        Text(
                          'Reglas de la casa',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: listing.houseRules.map((rule) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.textSecondaryDark,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      rule,
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppTheme.dividerDark),
                        const SizedBox(height: 24),
                      ],

                      // Mapa de Ubicación
                      if (listing.latitude != null &&
                          listing.longitude != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ubicación',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _openFullScreenMap,
                              icon: const Icon(Icons.fullscreen_rounded,
                                  size: 20),
                              label: const Text('Expandir'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _openFullScreenMap,
                          child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.borderDark),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  IgnorePointer(
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: LatLng(listing.latitude!,
                                            listing.longitude!),
                                        initialZoom: 15,
                                        interactionOptions:
                                            const InteractionOptions(
                                          flags: InteractiveFlag.none,
                                        ),
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName: 'com.haus.app',
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: LatLng(listing.latitude!,
                                                  listing.longitude!),
                                              width: 40,
                                              height: 40,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme
                                                          .primaryColor
                                                          .withOpacity(0.5),
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 2),
                                                ),
                                                child: const Icon(
                                                  Icons.home_rounded,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Gradient Overlay bottom
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 60,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.5),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Expand Badge
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceDark,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.open_in_full_rounded,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Botones flotantes
        floatingActionButton: _isOwnListing
            ? null
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    // Contactar Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isContactingHost ? null : _contactHost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceDarkElevated,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                  color: AppTheme.primaryColor, width: 1.5)),
                        ),
                        child: _isContactingHost
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                      AppTheme.primaryColor),
                                ),
                              )
                            : const Text(
                                'Contactar',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Request Button
                    Expanded(
                      child: BlocBuilder<RequestBloc, RequestState>(
                        builder: (context, state) {
                          bool isPending = false;
                          bool isApproved = false;
                          bool isLoading = state is RequestLoading;

                          if (state is RequestStatusLoaded &&
                              state.request != null) {
                            isPending = state.request!.isPending;
                            isApproved = state.request!.isApproved;
                          } else if (state is RequestOperationSuccess &&
                              state.request != null) {
                            isPending = state.request!.isPending;
                            isApproved = state.request!.isApproved;
                          }

                          String buttonText = 'Solicitar';
                          Color buttonColor = AppTheme.primaryColor;
                          Color textColor = Colors.black;
                          VoidCallback? action = _sendRequest;

                          if (isLoading) {
                            return ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black),
                                ),
                              ),
                            );
                          }

                          if (isPending) {
                            buttonText = 'Pendiente';
                            buttonColor = AppTheme.warningColor;
                            textColor = Colors.black;
                            action = null;
                          } else if (isApproved) {
                            buttonText = 'Aprobado';
                            buttonColor = AppTheme.successColor;
                            textColor = Colors.white;
                            action = null;
                          }

                          return ElevatedButton(
                            onPressed: action,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              disabledBackgroundColor:
                                  buttonColor.withOpacity(0.7),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 4,
                              shadowColor: buttonColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              buttonText,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

/// Pantalla de Mapa Pantalla Completa con Rutas
class FullScreenMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;

  const FullScreenMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  State<FullScreenMapView> createState() => _FullScreenMapViewState();
}

class _FullScreenMapViewState extends State<FullScreenMapView> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Los servicios de ubicación están desactivados.')),
        );
      }
      return;
    }

    // 2. Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Los permisos de ubicación están denegados permanentemente.')),
        );
      }
      return;
    }

    // 3. Obtener ubicación actual
    setState(() => _isLoadingRoute = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      // 4. Calcular ruta automáticamente una vez tenemos la ubicación
      await _getRoute();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  Future<void> _getRoute() async {
    if (_userLocation == null) return;

    final start = _userLocation!;
    final end = LatLng(widget.latitude, widget.longitude);

    // URL de OSRM (Demo Server) - Usar HTTPS
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');

    debugPrint('Requesting route: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] != 'Ok') {
          throw Exception('OSRM Error: ${data['code']}');
        }

        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'] as List;

          setState(() {
            _routePoints = coordinates
                .map(
                    (coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
                .toList();
          });

          // Ajustar el mapa para mostrar toda la ruta
          if (_routePoints.isNotEmpty) {
            // Pequeño delay para asegurar que el mapa se ha renderizado
            Future.delayed(const Duration(milliseconds: 100), () {
              final bounds = LatLngBounds.fromPoints(_routePoints);
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(50),
                ),
              );
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No se encontró una ruta disponible.')),
            );
          }
        }
      } else if (response.statusCode == 400) {
        // Error 400 suele ser "NoRoute" (ej: continentes distintos o sin calles)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No es posible trazar una ruta en auto hasta este destino (demasiado lejos o sin conexión).'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception(
            'Error API: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error calculating route: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular la ruta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Ubicación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.latitude, widget.longitude),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.haus.app',
              ),
              // Capa de Ruta (Polyline)
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Marcador de la Casa (Destino)
                  Marker(
                    point: LatLng(widget.latitude, widget.longitude),
                    width: 40,
                    height: 40,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                        border:
                            Border.all(color: AppTheme.primaryColor, width: 2),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                  // Marcador del Usuario (Origen)
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(
                              8), // Cuadrado con bordes redondeados
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person_rounded, // Icono de persona
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Botón Flotante para Calcular Ruta (Diseño Cuadrado)
          Positioned(
            bottom: 130, // Posicionado encima de la tarjeta de dirección
            right: 20,
            child: GestureDetector(
              onTap: _isLoadingRoute ? null : _getCurrentLocation,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16), // Filos redondos
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoadingRoute
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.directions_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
            ),
          ),

          // Tooltip de dirección
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderDark),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.address,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
