import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/data/ecuador_locations.dart';
import '../../domain/entities/listing_entity.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';
import 'location_picker_page.dart';

class CreateListingPage extends StatefulWidget {
  final String userId;

  const CreateListingPage({super.key, required this.userId});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Coordenadas seleccionadas
  LatLng? _selectedLocation;

  String? _selectedHousingType;
  String? _selectedCity;
  String? _selectedNeighborhood;

  final List<String> _housingTypes = [
    'Departamento',
    'Casa',
    'Suite',
    'Habitación',
    'Oficina',
    'Local Comercial',
    'Terreno',
    'Otro'
  ];

  // Amenities disponibles y seleccionados
  final List<String> _availableAmenities = [
    'Wifi',
    'Cocina',
    'Lavadora',
    'TV',
    'Aire Acondicionado',
    'Baño Privado',
    'Escritorio',
    'Gimnasio',
    'Pet Friendly',
    'Estacionamiento'
  ];
  final List<String> _selectedAmenities = [];

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  // Navegar al mapa para seleccionar ubicación
  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerPage()),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        // Opcional: Podrías llenar _addressController con lat/lng si quieres
        // _addressController.text = "${result.latitude}, ${result.longitude}";
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes agregar al menos una imagen')),
        );
        return;
      }

      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor selecciona una ubicación en el mapa')),
        );
        return;
      }

      final listing = ListingEntity(
        userId: widget.userId, // ID del usuario actual
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        housingType: _selectedHousingType!,
        city: _selectedCity!,
        neighborhood: _selectedNeighborhood!,
        address: _addressController.text,
        latitude: _selectedLocation!.latitude, // Enviamos latitud
        longitude: _selectedLocation!.longitude, // Enviamos longitud
        amenities: _selectedAmenities, // Enviamos amenities
        imageUrls: const [], // Se llenará en el servidor
      );

      context.read<ListingBloc>().add(
            CreateListingEvent(listing: listing, images: _selectedImages),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListingBloc, ListingState>(
      listener: (context, state) {
        if (state is ListingOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Volver atrás al terminar
        } else if (state is ListingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          title: const Text('Nueva Publicación'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<ListingBloc, ListingState>(
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección de Imágenes
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.borderDark),
                            ),
                            child: _selectedImages.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_rounded,
                                          size: 40,
                                          color: AppTheme.primaryColor),
                                      const SizedBox(height: 8),
                                      Text('Agregar Fotos',
                                          style: TextStyle(
                                              color:
                                                  AppTheme.textSecondaryDark)),
                                    ],
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _selectedImages.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                              _selectedImages[index]),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Inputs
                        _buildTextField(
                            controller: _titleController,
                            label: 'Título',
                            icon: Icons.title),
                        const SizedBox(height: 16),
                        _buildTextField(
                            controller: _priceController,
                            label: 'Precio mensual',
                            icon: Icons.attach_money,
                            isNumber: true),

                        const SizedBox(height: 16),

                        // Selectores nuevos
                        _buildDropdown(
                          label: 'Tipo de inmueble',
                          value: _selectedHousingType,
                          items: _housingTypes,
                          icon: Icons.home_work_outlined,
                          onChanged: (val) {
                            setState(() => _selectedHousingType = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildDropdown(
                          label: 'Ciudad',
                          value: _selectedCity,
                          items: EcuadorLocations.cities,
                          icon: Icons.location_city_rounded,
                          onChanged: (val) {
                            setState(() {
                              _selectedCity = val;
                              _selectedNeighborhood = null; // Reiniciar barrio
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildDropdown(
                          label: 'Barrio / Sector',
                          value: _selectedNeighborhood,
                          items: _selectedCity != null
                              ? EcuadorLocations.getNeighborhoods(
                                  _selectedCity!)
                              : [],
                          icon: Icons.map_outlined,
                          enabled: _selectedCity != null,
                          onChanged: (val) {
                            setState(() => _selectedNeighborhood = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLocationSelector(),
                        const SizedBox(height: 16),

                        _buildTextField(
                            controller: _addressController,
                            label: 'Dirección escrita (Referencia)',
                            icon: Icons.location_city),
                        const SizedBox(height: 16),
                        const Text(
                          'Servicios incluidos',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _availableAmenities.map((amenity) {
                            final isSelected =
                                _selectedAmenities.contains(amenity);
                            return FilterChip(
                              label: Text(amenity),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedAmenities.add(amenity);
                                  } else {
                                    _selectedAmenities.remove(amenity);
                                  }
                                });
                              },
                              backgroundColor: AppTheme.surfaceDark,
                              selectedColor:
                                  AppTheme.primaryColor.withOpacity(0.2),
                              checkmarkColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.borderDark,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                            controller: _descriptionController,
                            label: 'Descripción',
                            icon: Icons.description_outlined,
                            maxLines: 4),

                        const SizedBox(height: 30),

                        // Botón Publicar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state is ListingLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: state is ListingLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Publicar',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Overlay de carga (opcional si usas el botón con loading)
                if (state is ListingLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget para mostrar si ya seleccionó ubicación o invitar a hacerlo
  Widget _buildLocationSelector() {
    return GestureDetector(
      onTap: _pickLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _selectedLocation != null
                  ? AppTheme.primaryColor
                  : AppTheme.borderDark),
        ),
        child: Row(
          children: [
            Icon(Icons.map_rounded,
                color: _selectedLocation != null
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedLocation != null
                    ? 'Ubicación seleccionada (Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}...)'
                    : 'Seleccionar ubicación en el mapa',
                style: TextStyle(
                  color: _selectedLocation != null
                      ? Colors.white
                      : AppTheme.textSecondaryDark,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: AppTheme.textSecondaryDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (value) =>
          value == null || value.isEmpty ? 'Este campo es requerido' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondaryDark),
        prefixIcon: Icon(icon, color: AppTheme.textSecondaryDark),
        filled: true,
        fillColor: AppTheme.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (val) => val == null ? 'Requerido' : null,
      style: const TextStyle(color: Colors.white),
      dropdownColor: AppTheme.surfaceDark,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondaryDark),
        prefixIcon: Icon(icon,
            color: enabled ? AppTheme.textSecondaryDark : Colors.white24),
        filled: true,
        fillColor: AppTheme.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}
