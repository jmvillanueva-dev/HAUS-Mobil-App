import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/avatar_service.dart';
import '../../../../injection_container.dart';
import '../../../locations/domain/entities/user_location_entity.dart';
import '../../../locations/domain/repositories/location_repository.dart';
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
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  int _currentStep = 0;
  File? _selectedImage;
  bool _isUploading = false;
  String? _avatarUrl;
  LocationLabel _selectedLocationLabel = LocationLabel.work;

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
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bioController.dispose();
    _universityOrCompanyController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  int get _totalSteps => 5;

  String get _roleDisplayName {
    return widget.user.role == UserRole.student ? 'estudiante' : 'trabajador';
  }

  String get _universityOrCompanyLabel {
    return widget.user.role == UserRole.student ? 'Universidad' : 'Empresa';
  }

  String get _universityOrCompanyHint {
    return widget.user.role == UserRole.student
        ? 'Nombre de tu universidad'
        : 'Nombre de tu empresa';
  }

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
    if (_currentStep < _totalSteps - 1) {
      // Si estamos en el paso de foto y hay imagen seleccionada, subir
      if (_currentStep == 1 && _selectedImage != null && _avatarUrl == null) {
        await _uploadAvatar();
      }

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
      // Guardar ubicación si hay datos
      if (_addressController.text.trim().isNotEmpty ||
          _cityController.text.trim().isNotEmpty) {
        await _locationRepository.createLocation(
          userId: widget.user.id,
          label: _selectedLocationLabel,
          purpose: LocationPurpose.search,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          city: _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : null,
          neighborhood: _neighborhoodController.text.trim().isNotEmpty
              ? _neighborhoodController.text.trim()
              : null,
          isPrimary: true,
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
            ),
          );
    }
  }

  void _handleSkip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainPage(user: widget.user),
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
          TextButton(
            onPressed: _handleSkip,
            child: Text(
              'Omitir',
              style: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.2),
                AppTheme.primaryColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.waving_hand_rounded,
            size: 48,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          '¡Hola, ${widget.user.firstName ?? 'usuario'}!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Vamos a completar tu perfil de $_roleDisplayName para que puedas encontrar el roomie ideal.',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondaryDark,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildInfoCard(
          icon: Icons.camera_alt_rounded,
          title: 'Foto de perfil',
          description: 'Una buena foto aumenta la confianza.',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.location_on_rounded,
          title: 'Tu ubicación',
          description: 'Para encontrar roomies cercanos a ti.',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.person_rounded,
          title: 'Sobre ti',
          description: 'Cuéntanos un poco sobre tu estilo de vida.',
        ),
      ],
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Foto de perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Una foto ayuda a otros usuarios a conocerte mejor.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 32),

        // Avatar preview
        Center(
          child: Stack(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 60,
                        color: AppTheme.textSecondaryDark,
                      )
                    : null,
              ),
              if (_isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Buttons
        Row(
          children: [
            Expanded(
              child: _buildPhotoButton(
                icon: Icons.photo_library_rounded,
                label: 'Galería',
                onTap: () => _pickImage(false),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPhotoButton(
                icon: Icons.camera_alt_rounded,
                label: 'Cámara',
                onTap: () => _pickImage(true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          'Puedes omitir este paso y agregar una foto después.',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiaryDark,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Información de contacto',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Esta información te ayudará a conectar con otros usuarios.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _phoneController,
          label: 'Teléfono (opcional)',
          hint: '+593 999 999 999',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _universityOrCompanyController,
          label: _universityOrCompanyLabel,
          hint: _universityOrCompanyHint,
          prefixIcon: widget.user.role == UserRole.student
              ? Icons.school_outlined
              : Icons.business_outlined,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.infoColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppTheme.infoColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tu número de teléfono solo será visible para roomies con los que conectes.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.infoColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Tu ubicación',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa la ubicación de tu ${widget.user.role == UserRole.student ? "universidad" : "trabajo"} para encontrar roomies cerca.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 24),

        // Location type selector
        Row(
          children: [
            _buildLocationTypeChip(LocationLabel.university, 'Universidad'),
            const SizedBox(width: 8),
            _buildLocationTypeChip(LocationLabel.work, 'Trabajo'),
            const SizedBox(width: 8),
            _buildLocationTypeChip(LocationLabel.other, 'Otro'),
          ],
        ),
        const SizedBox(height: 24),

        CustomTextField(
          controller: _cityController,
          label: 'Ciudad',
          hint: 'Ej: Quito',
          prefixIcon: Icons.location_city_rounded,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _neighborhoodController,
          label: 'Barrio / Sector',
          hint: 'Ej: La Floresta',
          prefixIcon: Icons.map_rounded,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _addressController,
          label: 'Dirección (opcional)',
          hint: 'Calle principal y secundaria',
          prefixIcon: Icons.home_rounded,
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.warningColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.warningColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No te preocupes, más adelante podrás agregar más ubicaciones o editarlas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.warningColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTypeChip(LocationLabel label, String text) {
    final isSelected = _selectedLocationLabel == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedLocationLabel = label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.borderDark,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                label.icon,
                size: 20,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryDark,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Cuéntanos sobre ti',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Una buena descripción aumenta tus posibilidades de encontrar el roomie ideal.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _bioController,
          maxLines: 5,
          maxLength: 300,
          decoration: InputDecoration(
            labelText: 'Bio',
            hintText:
                '¿Qué te gusta hacer? ¿Cuál es tu rutina? ¿Qué buscas en un roomie?',
            alignLabelWithHint: true,
            filled: true,
            fillColor: AppTheme.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.borderDark),
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
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Ideas para tu bio:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSuggestionChip('🎮 Gamer'),
            _buildSuggestionChip('📚 Estudiante tranquilo'),
            _buildSuggestionChip('🌙 Ave nocturna'),
            _buildSuggestionChip('☀️ Madrugador'),
            _buildSuggestionChip('🧹 Ordenado'),
            _buildSuggestionChip('🎵 Amante de la música'),
            _buildSuggestionChip('🐕 Pet friendly'),
            _buildSuggestionChip('🚭 No fumador'),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        final currentText = _bioController.text;
        if (currentText.isEmpty) {
          _bioController.text = text;
        } else {
          _bioController.text = '$currentText $text';
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textPrimaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(color: AppTheme.borderDark),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _handleBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.borderDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Atrás',
                  style: TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.backgroundDark,
                        ),
                      )
                    : Text(
                        _currentStep == _totalSteps - 1
                            ? 'Completar'
                            : 'Continuar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.backgroundDark,
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
