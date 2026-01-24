import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_location_entity.dart';
import '../bloc/locations_bloc.dart';
import '../widgets/location_form.dart';

class AddLocationPage extends StatelessWidget {
  final String userId;

  const AddLocationPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
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
          'Nueva Ubicación',
          style: TextStyle(
            color: AppTheme.textPrimaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<LocationsBloc, LocationsState>(
        listener: (context, state) {
          if (state is LocationsLoaded) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ubicación agregada correctamente'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          } else if (state is LocationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              LocationForm(
                submitButtonText: 'Guardar Ubicación',
                onSubmit: ({
                  required label,
                  required city,
                  required neighborhood,
                  required address,
                  required latitude,
                  required longitude,
                }) {
                  final bloc = context.read<LocationsBloc>();
                  final state = bloc.state;

                  if (state is LocationsLoaded) {
                    // Check for duplicates
                    if (label == LocationLabel.university ||
                        label == LocationLabel.work) {
                      final hasDuplicate = state.locations.any(
                        (location) => location.label == label,
                      );

                      if (hasDuplicate) {
                        final labelText = label == LocationLabel.university
                            ? 'Universidad'
                            : 'Trabajo';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Ya tienes una ubicación registrada como $labelText'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                        return;
                      }
                    }
                  }

                  bloc.add(
                    AddLocation(
                      userId: userId,
                      label: label,
                      purpose: LocationPurpose.search, // Default purpose
                      address: address,
                      city: city,
                      neighborhood: neighborhood,
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add_location_alt_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agrega un lugar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Guarda tus ubicaciones frecuentes para encontrar roomies cerca.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryDark,
                    height: 1.4,
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
