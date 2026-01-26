import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../data/models/user_preferences_model.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/preferences_repository.dart';

/// Página de preferencias de convivencia - Diseño profesional limpio
class PreferencesPage extends StatefulWidget {
  final String userId;
  final VoidCallback? onComplete;

  const PreferencesPage({
    super.key,
    required this.userId,
    this.onComplete,
  });

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isSaving = false;

  late final PreferencesRepository _repository;
  late UserPreferencesModel _preferences;

  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = getIt<PreferencesRepository>();
    _preferences = UserPreferencesModel(id: '', userId: widget.userId);
    _loadExistingPreferences();
  }

  @override
  void dispose() {
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPreferences() async {
    setState(() => _isLoading = true);
    final result = await _repository.getMyPreferences();
    result.fold(
      (_) {},
      (prefs) {
        if (prefs != null) {
          setState(() {
            _preferences = UserPreferencesModel.fromEntity(prefs);
            _budgetMinController.text =
                prefs.budgetMin?.toStringAsFixed(0) ?? '';
            _budgetMaxController.text =
                prefs.budgetMax?.toStringAsFixed(0) ?? '';
          });
        }
      },
    );
    setState(() => _isLoading = false);
  }

  int get _totalSteps => 6;

  void _handleContinue() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      // Validate budget fields on last step
      final budgetMin = double.tryParse(_budgetMinController.text);
      final budgetMax = double.tryParse(_budgetMaxController.text);

      if (budgetMin == null || budgetMax == null) {
        _showSnackBar('Por favor ingresa tu rango de presupuesto',
            isError: true);
        return;
      }

      if (budgetMin <= 0 || budgetMax <= 0) {
        _showSnackBar('El presupuesto debe ser mayor a 0', isError: true);
        return;
      }

      if (budgetMin > budgetMax) {
        _showSnackBar('El mínimo no puede ser mayor al máximo', isError: true);
        return;
      }

      _savePreferences();
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    final budgetMin = double.tryParse(_budgetMinController.text);
    final budgetMax = double.tryParse(_budgetMaxController.text);
    final updatedPrefs = _preferences.copyWith(
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      preferencesCompleted: true,
    );
    final result = await _repository.savePreferences(updatedPrefs);
    setState(() => _isSaving = false);
    result.fold(
      (failure) => _showSnackBar('Error: ${failure.message}', isError: true),
      (_) {
        _showSnackBar('¡Preferencias guardadas!', isError: false);
        widget.onComplete?.call();
        Navigator.of(context).pop(true);
      },
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNav(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    child: _buildCurrentStep(),
                  ),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 70,
      leading: Center(
          child:
              _buildNavButton(Icons.arrow_back_ios_new_rounded, _handleBack)),
      title: Text(_getStepTitle(),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      centerTitle: true,
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Bienvenido';
      case 1:
        return 'Hábitos';
      case 2:
        return 'Estilo de Vida';
      case 3:
        return 'Actividades';
      case 4:
        return 'Roomie Ideal';
      case 5:
        return 'Presupuesto';
      default:
        return 'Preferencias';
    }
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Icon(icon, color: AppTheme.textPrimaryDark, size: 18),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _totalSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text('Paso ${_currentStep + 1}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark)),
              Text(' de $_totalSteps',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondaryDark)),
              const Spacer(),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: (MediaQuery.of(context).size.width - 48) * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
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
        return _buildHabitsStep();
      case 2:
        return _buildLifestyleStep();
      case 3:
        return _buildActivitiesStep();
      case 4:
        return _buildRoomieStep();
      case 5:
        return _buildBudgetStep();
      default:
        return _buildWelcomeStep();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 0: BIENVENIDA (Timeline)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.handshake_rounded,
              size: 44, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 16),
        const Text('Configura tus Preferencias',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryDark)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('5 pasos para encontrar a tu roomie ideal.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark)),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              _buildConnectedTimelineItem(1, 'Hábitos',
                  'Fumar, alcohol, mascotas', Icons.favorite_rounded, false),
              _buildConnectedTimelineItem(2, 'Estilo de Vida',
                  'Horarios, ruido, visitas', Icons.nightlife_rounded, false),
              _buildConnectedTimelineItem(3, 'Actividades',
                  'Intereses y hobbies', Icons.sports_esports_rounded, false),
              _buildConnectedTimelineItem(
                  4,
                  'Roomie Ideal',
                  'Qué buscas en un compañero',
                  Icons.person_search_rounded,
                  false),
              _buildConnectedTimelineItem(5, 'Presupuesto',
                  'Rango de precios mensual', Icons.attach_money_rounded, true),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildConnectedTimelineItem(
      int number, String title, String subtitle, IconData icon, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Side: Indicator with continuous line using Stack
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Vertical line (behind the number)
                if (!isLast)
                  Positioned(
                    top: 16, // Start from center of the number badge
                    bottom: 0,
                    child: Container(
                      width: 3,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                // Number badge (on top)
                Positioned(
                  top: 12, // Align with card center
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Center(
                      child: Text('$number',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right Side: Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderDark.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.textPrimaryDark)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryDark)),
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

  // ═══════════════════════════════════════════════════════════════════
  // STEP 1: HÁBITOS PERSONALES
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHabitsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.favorite_rounded,
          title: 'Hábitos Personales',
          subtitle: 'Cuéntanos sobre tus costumbres diarias',
        ),
        const SizedBox(height: 24),

        // Fumar
        _buildSectionTitle('¿Fumas?'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBigOption(
                label: 'Sí',
                icon: Icons.smoking_rooms_rounded,
                isSelected: _preferences.isSmoker,
                onTap: () => setState(
                    () => _preferences = _preferences.copyWith(isSmoker: true)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBigOption(
                label: 'No',
                icon: Icons.smoke_free_rounded,
                isSelected: !_preferences.isSmoker,
                onTap: () => setState(() =>
                    _preferences = _preferences.copyWith(isSmoker: false)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Alcohol
        _buildSectionTitle('Consumo de Alcohol'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBigOption(
                label: 'Nunca',
                isSelected: _preferences.drinksAlcohol == DrinksAlcohol.never,
                onTap: () => setState(() => _preferences =
                    _preferences.copyWith(drinksAlcohol: DrinksAlcohol.never)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Social',
                isSelected:
                    _preferences.drinksAlcohol == DrinksAlcohol.socially,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(drinksAlcohol: DrinksAlcohol.socially)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Regular',
                isSelected:
                    _preferences.drinksAlcohol == DrinksAlcohol.regularly,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(drinksAlcohol: DrinksAlcohol.regularly)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Mascotas
        _buildSectionTitle('Mascotas'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBigOption(
                label: 'Tengo mascota',
                icon: Icons.pets_rounded,
                isSelected: _preferences.hasPets,
                onTap: () => setState(
                    () => _preferences = _preferences.copyWith(hasPets: true)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBigOption(
                label: 'No tengo',
                icon: Icons.not_interested_rounded,
                isSelected: !_preferences.hasPets,
                onTap: () => setState(
                    () => _preferences = _preferences.copyWith(hasPets: false)),
              ),
            ),
          ],
        ),

        if (_preferences.hasPets) ...[
          const SizedBox(height: 16),
          _buildPetTypeSelector(),
        ],

        const SizedBox(height: 24),
        _buildInfoNote(
            'Esta información será visible en tu perfil para encontrar roomies compatibles.'),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: AppTheme.textPrimaryDark));
  }

  Widget _buildStepHeader(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceDarkElevated,
            AppTheme.surfaceDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppTheme.textPrimaryDark)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryDark,
                        height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigOption(
      {required String label,
      IconData? icon,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: icon != null ? 72 : 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.borderDark,
              width: isSelected ? 0 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: isSelected ? Colors.black : AppTheme.textPrimaryDark,
                  size: 20),
              const SizedBox(height: 6),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : AppTheme.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style:
                    TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildPetTypeSelector() {
    final pets = [
      ('Perro', 'dog', Icons.pets_rounded),
      ('Gato', 'cat', Icons.pets_rounded),
      ('Ave', 'bird', Icons.flutter_dash_rounded),
      ('Otro', 'other', Icons.more_horiz_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Qué mascota tienes?',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryDark)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: pets.map((pet) {
            final isSelected = _preferences.petType == pet.$2;
            return GestureDetector(
              onTap: () => setState(
                  () => _preferences = _preferences.copyWith(petType: pet.$2)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.15)
                      : AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.borderDark,
                      width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(pet.$3,
                        size: 16,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryDark),
                    const SizedBox(width: 8),
                    Text(pet.$1,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondaryDark)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 2: ESTILO DE VIDA
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildLifestyleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.nightlife_rounded,
          title: 'Estilo de Vida',
          subtitle: '¿Cómo es tu día a día en casa?',
        ),
        const SizedBox(height: 24),

        // Horario de sueño
        _buildSectionTitle('Horario de sueño'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBigOption(
                label: 'Temprano',
                icon: Icons.wb_sunny_rounded,
                isSelected:
                    _preferences.sleepSchedule == SleepSchedule.earlyBird,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(sleepSchedule: SleepSchedule.earlyBird)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Nocturno',
                icon: Icons.nights_stay_rounded,
                isSelected:
                    _preferences.sleepSchedule == SleepSchedule.nightOwl,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(sleepSchedule: SleepSchedule.nightOwl)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Flexible',
                icon: Icons.access_time_rounded,
                isSelected:
                    _preferences.sleepSchedule == SleepSchedule.flexible,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(sleepSchedule: SleepSchedule.flexible)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Nivel de ruido
        _buildSectionTitle('Nivel de ruido'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBigOption(
                label: 'Silencio',
                icon: Icons.volume_off_rounded,
                isSelected: _preferences.noiseLevel == NoiseLevel.quiet,
                onTap: () => setState(() => _preferences =
                    _preferences.copyWith(noiseLevel: NoiseLevel.quiet)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Moderado',
                icon: Icons.volume_down_rounded,
                isSelected: _preferences.noiseLevel == NoiseLevel.moderate,
                onTap: () => setState(() => _preferences =
                    _preferences.copyWith(noiseLevel: NoiseLevel.moderate)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Social',
                icon: Icons.volume_up_rounded,
                isSelected: _preferences.noiseLevel == NoiseLevel.social,
                onTap: () => setState(() => _preferences =
                    _preferences.copyWith(noiseLevel: NoiseLevel.social)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        _buildCleanlinessSlider(),

        const SizedBox(height: 20),

        // Visitas
        _buildSectionTitle('Visitas'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBigOption(
                label: 'Nunca',
                isSelected:
                    _preferences.guestsFrequency == GuestsFrequency.never,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(guestsFrequency: GuestsFrequency.never)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'A veces',
                isSelected:
                    _preferences.guestsFrequency == GuestsFrequency.sometimes,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(guestsFrequency: GuestsFrequency.sometimes)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Seguido',
                isSelected:
                    _preferences.guestsFrequency == GuestsFrequency.often,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(guestsFrequency: GuestsFrequency.often)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCleanlinessSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Nivel de orden',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryDark)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${_preferences.cleanlinessLevel}/5',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderDark.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.sentiment_satisfied_alt_rounded,
                  size: 20, color: AppTheme.textSecondaryDark),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: AppTheme.surfaceDarkElevated,
                    thumbColor: AppTheme.primaryColor,
                    overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _preferences.cleanlinessLevel.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (val) => setState(() => _preferences =
                        _preferences.copyWith(cleanlinessLevel: val.toInt())),
                  ),
                ),
              ),
              Icon(Icons.cleaning_services_rounded,
                  size: 20, color: AppTheme.textSecondaryDark),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 3: ACTIVIDADES
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildActivitiesStep() {
    final activities = [
      (
        Icons.fitness_center_rounded,
        'Ejercicio',
        _preferences.exercises,
        (bool v) => _preferences = _preferences.copyWith(exercises: v)
      ),
      (
        Icons.music_note_rounded,
        'Música',
        _preferences.playsMusic,
        (bool v) => _preferences = _preferences.copyWith(playsMusic: v)
      ),
      (
        Icons.sports_esports_rounded,
        'Videojuegos',
        _preferences.playsVideogames,
        (bool v) => _preferences = _preferences.copyWith(playsVideogames: v)
      ),
      (
        Icons.movie_rounded,
        'Películas',
        _preferences.watchesMovies,
        (bool v) => _preferences = _preferences.copyWith(watchesMovies: v)
      ),
      (
        Icons.menu_book_rounded,
        'Lectura',
        _preferences.likesReading,
        (bool v) => _preferences = _preferences.copyWith(likesReading: v)
      ),
      (
        Icons.nature_people_rounded,
        'Aire libre',
        _preferences.likesOutdoorActivities,
        (bool v) =>
            _preferences = _preferences.copyWith(likesOutdoorActivities: v)
      ),
      (
        Icons.celebration_rounded,
        'Fiestas',
        _preferences.likesParties,
        (bool v) => _preferences = _preferences.copyWith(likesParties: v)
      ),
      (
        Icons.restaurant_rounded,
        'Cocinar',
        _preferences.cookingFrequency != CookingFrequency.never,
        (bool v) => _preferences = _preferences.copyWith(
            cookingFrequency:
                v ? CookingFrequency.sometimes : CookingFrequency.never)
      ),
      (
        Icons.school_rounded,
        'Estudiar',
        _preferences.studiesAtHome,
        (bool v) => _preferences = _preferences.copyWith(studiesAtHome: v)
      ),
      (
        Icons.laptop_mac_rounded,
        'Home office',
        _preferences.worksFromHome,
        (bool v) => _preferences = _preferences.copyWith(worksFromHome: v)
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.sports_esports_rounded,
          title: 'Tus Intereses',
          subtitle: 'Selecciona lo que te identifica',
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: activities
              .map((a) => _buildActivityChip(
                  icon: a.$1,
                  label: a.$2,
                  selected: a.$3,
                  onTap: () => setState(() => a.$4(!a.$3))))
              .toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildActivityChip(
      {required IconData icon,
      required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor.withOpacity(0.15)
              : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppTheme.primaryColor : AppTheme.borderDark,
              width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryDark),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryDark)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 4: PREFERENCIAS DE ROOMIE
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildRoomieStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.person_search_rounded,
          title: '¿Qué buscas?',
          subtitle: 'Preferencias para tu futuro roomie',
        ),
        const SizedBox(height: 24),

        // Género
        _buildSectionTitle('Género'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBigOption(
                label: 'Hombre',
                icon: Icons.male_rounded,
                isSelected:
                    _preferences.preferredGender == GenderPreference.male,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(preferredGender: GenderPreference.male)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Mujer',
                icon: Icons.female_rounded,
                isSelected:
                    _preferences.preferredGender == GenderPreference.female,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(preferredGender: GenderPreference.female)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Cualquiera',
                icon: Icons.people_outline_rounded,
                isSelected:
                    _preferences.preferredGender == GenderPreference.any,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(preferredGender: GenderPreference.any)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Fumador
        _buildSectionTitle('¿Aceptas fumador?'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBigOption(
                label: 'Sí',
                icon: Icons.smoking_rooms_rounded,
                isSelected:
                    _preferences.preferredSmoker == SmokingPreference.yes,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(preferredSmoker: SmokingPreference.yes)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'No',
                icon: Icons.smoke_free_rounded,
                isSelected:
                    _preferences.preferredSmoker == SmokingPreference.no,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(preferredSmoker: SmokingPreference.no)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBigOption(
                label: 'Da igual',
                icon: Icons.help_outline_rounded,
                isSelected: _preferences.preferredSmoker ==
                    SmokingPreference.indifferent,
                onTap: () => setState(() => _preferences = _preferences
                    .copyWith(preferredSmoker: SmokingPreference.indifferent)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Mascotas
        _buildSectionTitle('¿Aceptas mascotas?'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBigOption(
                label: 'Sí',
                icon: Icons.pets_rounded,
                isSelected: _preferences.preferredPetFriendly,
                onTap: () => setState(() => _preferences =
                    _preferences.copyWith(preferredPetFriendly: true)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBigOption(
                label: 'No',
                icon: Icons.not_interested_rounded,
                isSelected: !_preferences.preferredPetFriendly,
                onTap: () => setState(() => _preferences =
                    _preferences.copyWith(preferredPetFriendly: false)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        _buildAgeRangeSlider(),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAgeRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Rango de edad',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryDark)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                  '${_preferences.preferredAgeMin} - ${_preferences.preferredAgeMax} años',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderDark.withOpacity(0.5)),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.surfaceDarkElevated,
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withOpacity(0.2),
              trackHeight: 4,
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 8,
                elevation: 2,
              ),
            ),
            child: RangeSlider(
              values: RangeValues(
                _preferences.preferredAgeMin.toDouble().clamp(18, 100),
                _preferences.preferredAgeMax.toDouble().clamp(18, 100),
              ),
              min: 18,
              max: 100,
              divisions: 82,
              onChanged: (v) => setState(() => _preferences =
                  _preferences.copyWith(
                      preferredAgeMin: v.start.toInt(),
                      preferredAgeMax: v.end.toInt())),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 5: PRESUPUESTO
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBudgetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.attach_money_rounded,
          title: 'Tu Presupuesto',
          subtitle: 'Define tu rango mensual en USD',
        ),
        const SizedBox(height: 24),

        // Required indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Este campo es obligatorio para participar en el matching.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade100,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Budget inputs with labels
        _buildSectionTitle('Rango de presupuesto mensual'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildBudgetField(_budgetMinController, 'Mínimo', '\$200'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 20, color: AppTheme.primaryColor),
              ),
            ),
            Expanded(
              child: _buildBudgetField(_budgetMaxController, 'Máximo', '\$800'),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Success card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.surfaceDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: Colors.black, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('¡Casi listo para el matching!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark)),
              const SizedBox(height: 8),
              Text(
                  'Al guardar tus preferencias, nuestro algoritmo te conectará con roomies compatibles.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryDark,
                      height: 1.5)),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFeatureChip(Icons.verified_rounded, 'Verificado'),
                  _buildFeatureChip(Icons.security_rounded, 'Seguro'),
                  _buildFeatureChip(Icons.flash_on_rounded, 'Rápido'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryDark)),
        ],
      ),
    );
  }

  Widget _buildBudgetField(
      TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 16,
              fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: AppTheme.textSecondaryDark.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppTheme.surfaceDark,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderDark)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderDark)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // COMPONENTES REUTILIZABLES
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildBottomNav() {
    final isLastStep = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
          color: AppTheme.backgroundDark,
          border:
              Border(top: BorderSide(color: AppTheme.borderDark, width: 0.5))),
      child: SafeArea(
        child: Row(children: [
          if (_currentStep > 0)
            Expanded(
                child: ElevatedButton(
                    onPressed: _handleBack,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: const Text('Atrás',
                        style: TextStyle(fontWeight: FontWeight.w600)))),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryDark]),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6))
                  ]),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(isLastStep ? 'Guardar' : 'Continuar',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
