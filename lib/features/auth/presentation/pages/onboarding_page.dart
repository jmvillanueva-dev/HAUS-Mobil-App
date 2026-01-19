import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import 'welcome_page.dart';

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

  int _currentStep = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _bioController.dispose();
    _universityOrCompanyController.dispose();
    super.dispose();
  }

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

  void _handleContinue() {
    if (_currentStep < 2) {
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

  void _handleComplete() {
    if (_formKey.currentState!.validate()) {
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
            ),
          );
    }
  }

  void _handleSkip() {
    // Navegar directamente a WelcomePage sin actualizar perfil
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WelcomePage(user: widget.user),
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
                builder: (_) => WelcomePage(user: state.user),
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
          final isLoading = state is ProfileUpdateLoading;

          return SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Progress indicator
                  _buildProgressIndicator(),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildCurrentStep(),
                    ),
                  ),

                  // Navigation buttons
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
          // Mini logo
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
          // Skip button
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
                'Paso ${_currentStep + 1} de 3',
                style: TextStyle(
                  color: AppTheme.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentStep + 1) / 3 * 100).toInt()}%',
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
              value: (_currentStep + 1) / 3,
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
        return _buildContactStep();
      case 2:
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

        // Welcome icon
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

        // Info cards
        _buildInfoCard(
          icon: Icons.search_rounded,
          title: 'Encuentra roomies compatibles',
          description:
              'Nuestro algoritmo te mostrará personas afines a tu estilo de vida.',
        ),
        const SizedBox(height: 12),

        _buildInfoCard(
          icon: Icons.verified_user_rounded,
          title: 'Perfiles verificados',
          description: 'Podrás verificar tu identidad para mayor confianza.',
        ),
        const SizedBox(height: 12),

        _buildInfoCard(
          icon: Icons.location_on_rounded,
          title: 'Ubicaciones cercanas',
          description: 'Busca roomies cerca de tu universidad o trabajo.',
        ),
      ],
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
        border: Border.all(
          color: AppTheme.borderDark,
          width: 1,
        ),
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
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
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

        // Phone field
        CustomTextField(
          controller: _phoneController,
          label: 'Teléfono (opcional)',
          hint: '+593 999 999 999',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // University/Company field
        CustomTextField(
          controller: _universityOrCompanyController,
          label: _universityOrCompanyLabel,
          hint: _universityOrCompanyHint,
          prefixIcon: widget.user.role == UserRole.student
              ? Icons.school_outlined
              : Icons.business_outlined,
        ),
        const SizedBox(height: 24),

        // Info note
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

        // Bio field
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

        // Suggestions
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
          border: Border.all(
            color: AppTheme.borderDark,
          ),
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

  Widget _buildNavigationButtons(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderDark,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
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

          // Continue button
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryDark,
                  ],
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
                        _currentStep == 2 ? 'Completar' : 'Continuar',
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
