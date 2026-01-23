import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart'; 
import '../../domain/entities/listing_entity.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes agregar al menos una imagen')),
        );
        return;
      }

      final listing = ListingEntity(
        userId: widget.userId, // ID del usuario actual
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        address: _addressController.text,
        amenities: const [], // TODO: Implementar selección de amenities
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
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
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
                                          size: 40, color: AppTheme.primaryColor),
                                      const SizedBox(height: 8),
                                      Text('Agregar Fotos',
                                          style: TextStyle(
                                              color: AppTheme.textSecondaryDark)),
                                    ],
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _selectedImages.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(_selectedImages[index]),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Inputs
                        _buildTextField(
                            controller: _titleController, label: 'Título', icon: Icons.title),
                        const SizedBox(height: 16),
                        _buildTextField(
                            controller: _priceController,
                            label: 'Precio mensual',
                            icon: Icons.attach_money,
                            isNumber: true),
                        const SizedBox(height: 16),
                        _buildTextField(
                            controller: _addressController,
                            label: 'Dirección / Zona',
                            icon: Icons.location_on_outlined),
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
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Publicar',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold)),
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
}