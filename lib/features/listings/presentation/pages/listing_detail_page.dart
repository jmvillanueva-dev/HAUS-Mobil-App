import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
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

class ListingDetailPage extends StatefulWidget {
  final ListingEntity listing;

  const ListingDetailPage({super.key, required this.listing});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
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

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Enviar Solicitud',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Quieres enviar una solicitud de interés al anfitrión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RequestBloc>().add(SendRequest(
                    listingId: listing.id!,
                    hostId: listing.userId,
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Enviar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<RequestBloc>()
        ..add(CheckRequestStatus(listingId: listing.id!)),
      child: BlocListener<RequestBloc, RequestState>(
        listener: (context, state) {
          if (state is RequestOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is RequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
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
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppTheme.backgroundDark,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                    foregroundColor: Colors.white,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: listing.imageUrls.isNotEmpty
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
                ),
              ),

              // 2. Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y Precio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceDarkElevated,
                                    borderRadius: BorderRadius.circular(6),
                                    border:
                                        Border.all(color: AppTheme.borderDark),
                                  ),
                                  child: Text(
                                    listing.housingType,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '\$${listing.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Dirección
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: AppTheme.textSecondaryDark),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${listing.neighborhood}, ${listing.city}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  listing.address,
                                  style: TextStyle(
                                      color: AppTheme.textSecondaryDark,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Descripción
                      const Text(
                        'Descripción',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing.description,
                        style: TextStyle(
                            color: AppTheme.textSecondaryDark, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Servicios (Amenities)
                      if (listing.amenities.isNotEmpty) ...[
                        const Text(
                          'Lo que ofrece este lugar',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: listing.amenities.map((amenity) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.borderDark),
                              ),
                              child: Text(
                                amenity,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Reglas de la casa
                      if (listing.houseRules.isNotEmpty) ...[
                        const Text(
                          'Reglas de la casa',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: listing.houseRules.map((rule) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.borderDark),
                              ),
                              child: Text(
                                rule,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Mapa de Ubicación (MEJORADO - EXPANDIBLE)
                      if (listing.latitude != null &&
                          listing.longitude != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ubicación',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            TextButton.icon(
                              onPressed: _openFullScreenMap,
                              icon: const Icon(Icons.fullscreen,
                                  color: AppTheme.primaryColor),
                              label: const Text(
                                'Expandir mapa',
                                style: TextStyle(color: AppTheme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          // Tap para abrir full screen
                          onTap: _openFullScreenMap,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.borderDark),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  // Mapa NO interactivo (solo visual)
                                  IgnorePointer(
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: LatLng(listing.latitude!,
                                            listing.longitude!),
                                        initialZoom: 15,
                                        interactionOptions:
                                            const InteractionOptions(
                                          flags: InteractiveFlag
                                              .none, // Deshabilita gestos
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
                                              child: const Icon(
                                                  Icons.location_on,
                                                  color: AppTheme.primaryColor,
                                                  size: 40),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Overlay para indicar que es interactivo
                                  Container(
                                    color: Colors
                                        .transparent, // Recibe el tap del GestureDetector
                                  ),
                                  // Badge de Expandir
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.open_in_full_rounded,
                                        color: Colors.white,
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
                      const SizedBox(height: 100), // Espacio extra al final
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Botón flotante de contacto - solo si no es el dueño
          floatingActionButton: _isOwnListing
              ? null
              : Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    children: [
                      // Contactar Button (Existing)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isContactingHost ? null : _contactHost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.surfaceDarkElevated, // Secondary style
                            disabledBackgroundColor:
                                AppTheme.surfaceDark.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: AppTheme.primaryColor)),
                          ),
                          child: _isContactingHost
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        AppTheme.primaryColor),
                                  ),
                                )
                              : const Text(
                                  'Contactar',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Request Button (New)
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

                            String buttonText = 'Solicitud';
                            Color buttonColor = AppTheme.primaryColor;
                            VoidCallback? action = _sendRequest;

                            if (isLoading) {
                              return ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                              );
                            }

                            if (isPending) {
                              buttonText = 'Pendiente';
                              buttonColor = Colors.orange;
                              action = null;
                            } else if (isApproved) {
                              buttonText = 'Aprobado';
                              buttonColor = Colors.green;
                              action = null; // Maybe open details?
                            }

                            return ElevatedButton(
                              onPressed: action,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                disabledBackgroundColor:
                                    buttonColor.withOpacity(0.6),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                buttonText,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ), // End Scaffold
      ), // End BlocListener
    ); // End BlocProvider
  }
}

/// Pantalla de Mapa Pantalla Completa
class FullScreenMapView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: Text('Mapa', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(latitude, longitude),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.haus.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(latitude, longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on,
                        color: AppTheme.primaryColor, size: 40),
                  ),
                ],
              ),
            ],
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
                      address,
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
