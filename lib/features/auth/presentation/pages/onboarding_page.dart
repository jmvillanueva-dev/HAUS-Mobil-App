import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/avatar_service.dart';
import '../../../../core/data/ecuador_locations.dart';
import '../../../../injection_container.dart';
import '../../../locations/domain/entities/user_location_entity.dart';
import '../../../locations/domain/repositories/location_repository.dart';
import '../../../locations/presentation/widgets/mini_map_picker.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../../../home/presentation/pages/main_page.dart';

/// Página de Onboarding para completar el perfil después del registro
class OnboardingPage extends StatefulWidget {
  final UserEntity user;

  const OnboardingPage({
    super.key,
    required this.user,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _universityOrCompanyController = TextEditingController();
  final _addressController = TextEditingController();

  int _currentStep = 0;
  File? _selectedImage;
  bool _isUploading = false;
  String? _avatarUrl;
  LocationLabel _selectedLocationLabel = LocationLabel.work;
  bool _isUniversity = true; // Selector para tipo de organización
  LatLng? _selectedCoordinates; // Coordenadas seleccionadas del mapa

  // Selección de ciudad y barrio
  String? _selectedCity;
  String? _selectedNeighborhood;

  late final AvatarService _avatarService;
  late final LocationRepository _locationRepository;

  @override
  void initState() {
    super.initState();
    _avatarService = getIt<AvatarService>();
    _locationRepository = getIt<LocationRepository>();

    // Pre-fill con datos existentes
    _universityOrCompanyController.text = widget.user.universityOrCompany ?? '';
    _bioController.text = widget.user.bio ?? '';
    _phoneController.text = widget.user.phone ?? '';
    _selectedLocationLabel = widget.user.role == UserRole.student
        ? LocationLabel.university
        : LocationLabel.work;
    _isUniversity = widget.user.role == UserRole.student;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bioController.dispose();
    _universityOrCompanyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  int get _totalSteps => 5;

  Future<void> _pickImage(bool fromCamera) async {
    File? image;
    if (fromCamera) {
      image = await _avatarService.captureFromCamera();
    } else {
      image = await _avatarService.pickFromGallery();
    }

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    final avatarPath = await _avatarService.uploadAvatar(
      widget.user.id,
      _selectedImage!,
    );

    if (avatarPath != null) {
      _avatarUrl = _avatarService.getAvatarPublicUrl(avatarPath);
    }

    setState(() => _isUploading = false);
  }

  void _handleContinue() async {
    // Validación según el paso actual
    if (_currentStep == 1) {
      // Paso de foto: obligatorio
      if (_selectedImage == null && _avatarUrl == null) {
        _showValidationError('Debes agregar una foto de perfil para continuar');
        return;
      }
      if (_selectedImage != null && _avatarUrl == null) {
        await _uploadAvatar();
      }
    } else if (_currentStep == 2) {
      // Paso de contacto: validar campos obligatorios
      if (_phoneController.text.trim().isEmpty) {
        _showValidationError('El número de teléfono es obligatorio');
        return;
      }
      if (_universityOrCompanyController.text.trim().isEmpty) {
        _showValidationError('Debes ingresar tu universidad o empresa');
        return;
      }
    } else if (_currentStep == 3) {
      // Paso de ubicación: ciudad es obligatoria
      if (_selectedCity == null || _selectedCity!.isEmpty) {
        _showValidationError('Debes seleccionar una ciudad');
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _handleComplete();
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _handleComplete() async {
    if (_formKey.currentState!.validate()) {
      // Guardar ubicación si hay datos o coordenadas
      if (_addressController.text.trim().isNotEmpty ||
          _selectedCity != null ||
          _selectedCoordinates != null) {
        await _locationRepository.createLocation(
          userId: widget.user.id,
          label: _selectedLocationLabel,
          purpose: LocationPurpose.search,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          city: _selectedCity,
          neighborhood: _selectedNeighborhood,
          latitude: _selectedCoordinates?.latitude,
          longitude: _selectedCoordinates?.longitude,
        );
      }

      // Verificar que el widget sigue montado
      if (!mounted) return;

      // Actualizar perfil
      context.read<AuthBloc>().add(
            UpdateProfileRequested(
              firstName: widget.user.firstName,
              lastName: widget.user.lastName,
              phone: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
              bio: _bioController.text.trim().isNotEmpty
                  ? _bioController.text.trim()
                  : null,
              universityOrCompany:
                  _universityOrCompanyController.text.trim().isNotEmpty
                      ? _universityOrCompanyController.text.trim()
                      : null,
              avatarUrl: _avatarUrl,
              onboardingCompleted: true,
            ),
          );
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MainPage(user: state.user),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileUpdateLoading || _isUploading;

          return SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProgressIndicator(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildCurrentStep(),
                    ),
                  ),
                  _buildNavigationButtons(isLoading),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.home_rounded,
              size: 20,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'HAUS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // Botón de omitir eliminado - onboarding es obligatorio
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Paso ${_currentStep + 1} de $_totalSteps',
                style: TextStyle(
                  color: AppTheme.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: AppTheme.surfaceDark,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildPhotoStep();
      case 2:
        return _buildContactStep();
      case 3:
        return _buildLocationStep();
      case 4:
        return _buildAboutStep();
      default:
        return _buildWelcomeStep();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 5),

        // Icono principal compacto
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.15),
                      AppTheme.primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.home_rounded,
                    size: 32, color: Colors.white),
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        // Saludo compacto
        Text(
          'Bienvenido a HAUS',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.user.firstName ?? 'Usuario',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 2),

        Text(
          'Completa tu perfil para conectar con roomies compatibles.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryDark,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // Timeline compacto
        _buildWelcomeTimelineItem(
          stepNumber: 1,
          icon: Icons.camera_alt_rounded,
          title: 'Foto de perfil',
          description: 'Genera confianza con una foto real',
          isFirst: true,
        ),
        _buildWelcomeTimelineItem(
          stepNumber: 2,
          icon: Icons.phone_rounded,
          title: 'Datos de contacto',
          description: 'Universidad o empresa',
        ),
        _buildWelcomeTimelineItem(
          stepNumber: 3,
          icon: Icons.location_on_rounded,
          title: 'Ubicacion',
          description: 'Para encontrar roomies cerca',
        ),
        _buildWelcomeTimelineItem(
          stepNumber: 4,
          icon: Icons.person_rounded,
          title: 'Sobre ti',
          description: 'Tu estilo de vida',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildWelcomeTimelineItem({
    required int stepNumber,
    required IconData icon,
    required String title,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline connector
          SizedBox(
            width: 36,
            child: Column(
              children: [
                // Línea superior (conecta con item anterior)
                Container(
                  width: 2,
                  height: 8,
                  color: isFirst ? Colors.transparent : AppTheme.primaryColor,
                ),
                // Número del paso
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Línea inferior (conecta con siguiente item)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Contenido
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppTheme.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryDark,
                          ),
                        ),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryDark,
                          ),
                        ),
                      ],
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

  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Header compacto
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Foto de perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  Text(
                    'Una foto real genera más confianza',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Avatar preview con efecto premium
        Center(
          child: Stack(
            children: [
              // Anillo exterior decorativo
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
              // Avatar principal
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Agregar foto',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              // Indicador de carga
              if (_isUploading)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 144,
                    height: 144,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Botones con diseño moderno
        Row(
          children: [
            Expanded(
              child: _buildPhotoButton(
                icon: Icons.photo_library_rounded,
                label: 'Galería',
                onTap: () => _pickImage(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPhotoButton(
                icon: Icons.camera_alt_rounded,
                label: 'Cámara',
                onTap: () => _pickImage(true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

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
                Icons.info_outline_rounded,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tu foto será visible para otros usuarios de HAUS',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Header compacto (mismo estilo que foto)
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
              ),
              child: const Icon(Icons.contact_phone_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos de contacto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  Text(
                    'Para conectar con otros usuarios',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Campo teléfono
        CustomTextField(
          controller: _phoneController,
          label: 'Teléfono',
          hint: '0991234567',
          prefixIcon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu número de teléfono';
            }
            if (value.length != 10) {
              return 'El número debe tener 10 dígitos';
            }
            return null;
          },
        ),

        const SizedBox(height: 24),

        // Selector de tipo de organización
        const Text(
          'Tipo de organización',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOrganizationTypeChip(
                isSelected: _isUniversity,
                icon: Icons.school_rounded,
                label: 'Universidad',
                onTap: () => setState(() => _isUniversity = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOrganizationTypeChip(
                isSelected: !_isUniversity,
                icon: Icons.business_rounded,
                label: 'Empresa',
                onTap: () => setState(() => _isUniversity = false),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Campo universidad/empresa
        CustomTextField(
          controller: _universityOrCompanyController,
          label: _isUniversity ? 'Universidad' : 'Empresa',
          hint: _isUniversity
              ? 'Nombre de tu universidad'
              : 'Nombre de tu empresa',
          prefixIcon:
              _isUniversity ? Icons.school_outlined : Icons.business_outlined,
          maxLength: 60,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _isUniversity
                  ? 'Ingresa el nombre de tu universidad'
                  : 'Ingresa el nombre de tu empresa';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

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
                Icons.lock_outline_rounded,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tu teléfono solo será visible para roomies con los que conectes',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationTypeChip({
    required bool isSelected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  )
                : null,
            color: isSelected ? null : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: isSelected ? null : Border.all(color: AppTheme.borderDark),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Header compacto (mismo estilo)
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu ubicación',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  Text(
                    'Para encontrar roomies cerca de ti',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

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
      ],
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
              _selectedNeighborhood = null; // Reset barrio al cambiar ciudad
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

  Widget _buildAboutStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Header compacto (mismo estilo)
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
              ),
              child: const Icon(Icons.edit_note_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cuéntanos sobre ti',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  Text(
                    'Tu bio ayuda a encontrar el roomie ideal',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Campo de bio mejorado
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _bioController,
            maxLines: 5,
            maxLength: 300,
            style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText:
                  '¿Qué te gusta hacer? ¿Cuál es tu rutina? ¿Qué buscas en un roomie?',
              hintStyle: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppTheme.surfaceDark,
              counterStyle: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontSize: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Título de sugerencias
        const Text(
          'Toca para agregar a tu bio:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 12),

        // Chips de sugerencias mejorados
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            _buildSuggestionChip('Gamer', 'Gamer'),
            _buildSuggestionChip(
                'Estudiante tranquilo', 'Estudiante tranquilo'),
            _buildSuggestionChip('Nocturno', 'Nocturno'),
            _buildSuggestionChip('Madrugador', 'Madrugador'),
            _buildSuggestionChip('Ordenado', 'Ordenado'),
            _buildSuggestionChip('Amante de la música', 'Amante de la música'),
            _buildSuggestionChip('Pet friendly', 'Pet friendly'),
            _buildSuggestionChip('No fumador', 'No fumador'),
            _buildSuggestionChip('Fitness', 'Fitness'),
            _buildSuggestionChip('Cocinero', 'Cocinero'),
          ],
        ),

        const SizedBox(height: 20),

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
                Icons.lightbulb_rounded,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sé auténtico, los perfiles honestos generan mejores conexiones',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String displayText, String valueText) {
    final isInBio =
        _bioController.text.toLowerCase().contains(valueText.toLowerCase());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final currentText = _bioController.text;
          if (!isInBio) {
            if (currentText.isEmpty) {
              _bioController.text = valueText;
            } else {
              _bioController.text = '$currentText, $valueText';
            }
            setState(() {}); // Actualizar UI
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isInBio
                ? LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  )
                : null,
            color: isInBio ? null : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: isInBio ? null : Border.all(color: AppTheme.borderDark),
            boxShadow: isInBio
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isInBio ? FontWeight.w600 : FontWeight.normal,
                  color: isInBio ? Colors.white : AppTheme.textPrimaryDark,
                ),
              ),
              if (isInBio) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: TextButton(
                onPressed: _handleBack,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Atrás',
                  style: TextStyle(
                    color: AppTheme
                        .backgroundDark, // Texto oscuro para contraste con fondo blanco
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _currentStep == _totalSteps - 1
                            ? 'Completar Perfil'
                            : 'Continuar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
