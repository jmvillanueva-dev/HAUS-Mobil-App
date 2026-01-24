import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget compacto de mapa para seleccionar ubicación
/// Usado en el onboarding y otros flujos que requieran selección de coordenadas
class MiniMapPicker extends StatefulWidget {
  /// Coordenadas iniciales (opcional)
  final LatLng? initialLocation;

  /// Callback cuando se selecciona una ubicación
  final ValueChanged<LatLng> onLocationSelected;

  /// Altura del widget
  final double height;

  /// Si mostrar botón de "Mi ubicación"
  final bool showMyLocationButton;

  const MiniMapPicker({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
    this.height = 200,
    this.showMyLocationButton = true,
  });

  @override
  State<MiniMapPicker> createState() => _MiniMapPickerState();
}

class _MiniMapPickerState extends State<MiniMapPicker> {
  final MapController _mapController = MapController();
  late LatLng _currentCenter;
  bool _isLoading = false;
  bool _hasSelectedLocation = false;

  @override
  void initState() {
    super.initState();
    // Default: Quito, Ecuador
    _currentCenter = widget.initialLocation ?? const LatLng(-0.1807, -78.4678);

    if (widget.initialLocation != null) {
      _hasSelectedLocation = true;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Verificar servicio de ubicación
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('El GPS está desactivado');
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Permiso de ubicación denegado');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Permiso de ubicación denegado permanentemente');
        return;
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _hasSelectedLocation = true;
      });

      _mapController.move(_currentCenter, 16);
      widget.onLocationSelected(_currentCenter);
    } catch (e) {
      _showLocationError('Error al obtener ubicación');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLocationError(String message) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      setState(() {
        _currentCenter = camera.center;
        _hasSelectedLocation = true;
      });
    }
  }

  void _confirmLocation() {
    widget.onLocationSelected(_currentCenter);
    setState(() => _hasSelectedLocation = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasSelectedLocation
              ? AppTheme.primaryColor
              : AppTheme.borderDark,
          width: _hasSelectedLocation ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              onPositionChanged: _onMapPositionChanged,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.haus.app',
              ),
            ],
          ),

          // Marcador central fijo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: AppTheme.primaryColor,
                    size: 40,
                  ),
                ),
                // Sombra del pin
                Container(
                  width: 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),

          // Botón mi ubicación
          if (widget.showMyLocationButton)
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _getCurrentLocation,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.my_location,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

          // Botón confirmar ubicación
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _confirmLocation,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasSelectedLocation
                            ? Icons.check_circle
                            : Icons.touch_app,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasSelectedLocation
                            ? 'Ubicación confirmada'
                            : 'Confirmar ubicación',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Indicador de coordenadas (esquina superior izquierda)
          if (_hasSelectedLocation)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentCenter.latitude.toStringAsFixed(4)}, ${_currentCenter.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: AppTheme.textSecondaryDark,
                        fontSize: 10,
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
