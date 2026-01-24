import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/data/ecuador_locations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../domain/entities/user_location_entity.dart';
import 'mini_map_picker.dart';

class LocationForm extends StatefulWidget {
  final LocationLabel? initialLabel;
  final String? initialCity;
  final String? initialNeighborhood;
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;
  final String submitButtonText;
  final Function({
    required LocationLabel label,
    required String? city,
    required String? neighborhood,
    required String address,
    required double? latitude,
    required double? longitude,
  }) onSubmit;

  const LocationForm({
    super.key,
    this.initialLabel,
    this.initialCity,
    this.initialNeighborhood,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
    required this.submitButtonText,
    required this.onSubmit,
  });

  @override
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late LocationLabel _selectedLocationLabel;
  String? _selectedCity;
  String? _selectedNeighborhood;
  LatLng? _selectedCoordinates;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    _selectedLocationLabel = widget.initialLabel ?? LocationLabel.work;
    _selectedCity = widget.initialCity;
    _selectedNeighborhood = widget.initialNeighborhood;
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedCoordinates =
          LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una ciudad')),
        );
        return;
      }

      widget.onSubmit(
        label: _selectedLocationLabel,
        city: _selectedCity,
        neighborhood: _selectedNeighborhood,
        address: _addressController.text.trim(),
        latitude: _selectedCoordinates?.latitude,
        longitude: _selectedCoordinates?.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tipo de ubicación
          const Text(
            'Tipo de ubicación',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLocationTypeChip(LocationLabel.university, 'Universidad'),
              const SizedBox(width: 10),
              _buildLocationTypeChip(LocationLabel.work, 'Trabajo'),
              const SizedBox(width: 10),
              _buildLocationTypeChip(LocationLabel.other, 'Otro'),
            ],
          ),

          const SizedBox(height: 24),

          // Selector de ciudad
          _buildCityDropdown(),

          const SizedBox(height: 14),

          // Selector de barrio
          _buildNeighborhoodDropdown(),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _addressController,
            label: 'Dirección (opcional)',
            hint: 'Calle principal y secundaria',
            prefixIcon: Icons.home_rounded,
            maxLength: 100,
          ),

          const SizedBox(height: 20),

          // Sección del mapa
          const Text(
            'Selecciona tu ubicación en el mapa',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),

          // Mini mapa para seleccionar coordenadas
          MiniMapPicker(
            initialLocation: _selectedCoordinates,
            height: 200,
            onLocationSelected: (coordinates) {
              setState(() {
                _selectedCoordinates = coordinates;
              });
            },
          ),

          const SizedBox(height: 16),

          // Mensaje informativo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mueve el mapa para ajustar tu ubicación exacta',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          _buildSubmitButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLocationTypeChip(LocationLabel label, String text) {
    final isSelected = _selectedLocationLabel == label;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedLocationLabel = label),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                    )
                  : null,
              color: isSelected ? null : AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border:
                  isSelected ? null : Border.all(color: AppTheme.borderDark),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  label.icon,
                  size: 22,
                  color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? Colors.white : AppTheme.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedCity != null
              ? AppTheme.primaryColor
              : AppTheme.borderDark,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          hint: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.location_city_rounded,
                  color: AppTheme.textSecondaryDark, size: 20),
              const SizedBox(width: 12),
              Text(
                'Selecciona tu ciudad',
                style: TextStyle(
                  color: AppTheme.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          icon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondaryDark),
          ),
          dropdownColor: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(vertical: 4),
          items: EcuadorLocations.cities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.location_city_rounded,
                      color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    city,
                    style: const TextStyle(
                      color: AppTheme.textPrimaryDark,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
              _selectedNeighborhood = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildNeighborhoodDropdown() {
    final neighborhoods = _selectedCity != null
        ? EcuadorLocations.getNeighborhoods(_selectedCity!)
        : <String>[];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedNeighborhood != null
              ? AppTheme.primaryColor
              : AppTheme.borderDark,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedNeighborhood,
          isExpanded: true,
          hint: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.map_rounded,
                  color: AppTheme.textSecondaryDark, size: 20),
              const SizedBox(width: 12),
              Text(
                _selectedCity == null
                    ? 'Primero selecciona una ciudad'
                    : 'Selecciona tu barrio',
                style: TextStyle(
                  color: AppTheme.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          icon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondaryDark),
          ),
          dropdownColor: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(vertical: 4),
          items: neighborhoods.map((neighborhood) {
            return DropdownMenuItem<String>(
              value: neighborhood,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.map_rounded,
                      color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    neighborhood,
                    style: const TextStyle(
                      color: AppTheme.textPrimaryDark,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: _selectedCity == null
              ? null
              : (value) {
                  setState(() {
                    _selectedNeighborhood = value;
                  });
                },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          widget.submitButtonText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
