import 'package:equatable/equatable.dart';

/// Enums para preferencias de usuario

enum DrinksAlcohol { never, socially, regularly }

enum SleepSchedule { earlyBird, nightOwl, flexible }

enum WorkSchedule { morning, afternoon, night, remote, flexible }

enum NoiseLevel { quiet, moderate, social }

enum GuestsFrequency { never, rarely, sometimes, often }

enum ExerciseFrequency { never, sometimes, regularly, daily }

enum DietPreference { none, vegetarian, vegan, keto, other }

enum CookingFrequency { never, sometimes, often, daily }

enum GenderPreference { male, female, any }

enum SmokingPreference { yes, no, indifferent }

enum PreferredNoiseLevel { quiet, moderate, social, any }

/// Extensiones para convertir enums a/desde strings de base de datos
extension DrinksAlcoholX on DrinksAlcohol {
  String toDbString() => name;
  static DrinksAlcohol fromString(String? value) {
    switch (value) {
      case 'never':
        return DrinksAlcohol.never;
      case 'regularly':
        return DrinksAlcohol.regularly;
      default:
        return DrinksAlcohol.socially;
    }
  }
}

extension SleepScheduleX on SleepSchedule {
  String toDbString() {
    switch (this) {
      case SleepSchedule.earlyBird:
        return 'early_bird';
      case SleepSchedule.nightOwl:
        return 'night_owl';
      case SleepSchedule.flexible:
        return 'flexible';
    }
  }

  static SleepSchedule fromString(String? value) {
    switch (value) {
      case 'early_bird':
        return SleepSchedule.earlyBird;
      case 'night_owl':
        return SleepSchedule.nightOwl;
      default:
        return SleepSchedule.flexible;
    }
  }
}

extension WorkScheduleX on WorkSchedule {
  String toDbString() => name;
  static WorkSchedule fromString(String? value) {
    switch (value) {
      case 'morning':
        return WorkSchedule.morning;
      case 'afternoon':
        return WorkSchedule.afternoon;
      case 'night':
        return WorkSchedule.night;
      case 'remote':
        return WorkSchedule.remote;
      default:
        return WorkSchedule.flexible;
    }
  }
}

extension NoiseLevelX on NoiseLevel {
  String toDbString() => name;
  static NoiseLevel fromString(String? value) {
    switch (value) {
      case 'quiet':
        return NoiseLevel.quiet;
      case 'social':
        return NoiseLevel.social;
      default:
        return NoiseLevel.moderate;
    }
  }
}

extension GuestsFrequencyX on GuestsFrequency {
  String toDbString() => name;
  static GuestsFrequency fromString(String? value) {
    switch (value) {
      case 'never':
        return GuestsFrequency.never;
      case 'rarely':
        return GuestsFrequency.rarely;
      case 'often':
        return GuestsFrequency.often;
      default:
        return GuestsFrequency.sometimes;
    }
  }
}

extension ExerciseFrequencyX on ExerciseFrequency {
  String toDbString() => name;
  static ExerciseFrequency fromString(String? value) {
    switch (value) {
      case 'sometimes':
        return ExerciseFrequency.sometimes;
      case 'regularly':
        return ExerciseFrequency.regularly;
      case 'daily':
        return ExerciseFrequency.daily;
      default:
        return ExerciseFrequency.never;
    }
  }
}

extension DietPreferenceX on DietPreference {
  String toDbString() => name;
  static DietPreference fromString(String? value) {
    switch (value) {
      case 'vegetarian':
        return DietPreference.vegetarian;
      case 'vegan':
        return DietPreference.vegan;
      case 'keto':
        return DietPreference.keto;
      case 'other':
        return DietPreference.other;
      default:
        return DietPreference.none;
    }
  }
}

extension CookingFrequencyX on CookingFrequency {
  String toDbString() => name;
  static CookingFrequency fromString(String? value) {
    switch (value) {
      case 'never':
        return CookingFrequency.never;
      case 'often':
        return CookingFrequency.often;
      case 'daily':
        return CookingFrequency.daily;
      default:
        return CookingFrequency.sometimes;
    }
  }
}

extension GenderPreferenceX on GenderPreference {
  String toDbString() => name;
  static GenderPreference fromString(String? value) {
    switch (value) {
      case 'male':
        return GenderPreference.male;
      case 'female':
        return GenderPreference.female;
      default:
        return GenderPreference.any;
    }
  }
}

extension SmokingPreferenceX on SmokingPreference {
  String toDbString() => name;
  static SmokingPreference fromString(String? value) {
    switch (value) {
      case 'yes':
        return SmokingPreference.yes;
      case 'no':
        return SmokingPreference.no;
      default:
        return SmokingPreference.indifferent;
    }
  }
}

extension PreferredNoiseLevelX on PreferredNoiseLevel {
  String toDbString() => name;
  static PreferredNoiseLevel fromString(String? value) {
    switch (value) {
      case 'quiet':
        return PreferredNoiseLevel.quiet;
      case 'moderate':
        return PreferredNoiseLevel.moderate;
      case 'social':
        return PreferredNoiseLevel.social;
      default:
        return PreferredNoiseLevel.any;
    }
  }
}

/// Entity que representa las preferencias de un usuario para matching
class UserPreferencesEntity extends Equatable {
  final String id;
  final String userId;

  // ═══════════════════════════════════════════════════
  // HÁBITOS PERSONALES
  // ═══════════════════════════════════════════════════
  final bool isSmoker;
  final DrinksAlcohol drinksAlcohol;
  final bool hasPets;
  final String? petType;

  // ═══════════════════════════════════════════════════
  // ESTILO DE VIDA
  // ═══════════════════════════════════════════════════
  final SleepSchedule sleepSchedule;
  final WorkSchedule workSchedule;
  final NoiseLevel noiseLevel;
  final int cleanlinessLevel; // 1-5
  final GuestsFrequency guestsFrequency;

  // ═══════════════════════════════════════════════════
  // ACTIVIDADES & INTERESES
  // ═══════════════════════════════════════════════════
  final bool exercises;
  final ExerciseFrequency exerciseFrequency;
  final DietPreference dietPreference;
  final CookingFrequency cookingFrequency;
  final bool studiesAtHome;
  final bool worksFromHome;
  final bool playsMusic;
  final bool playsVideogames;
  final bool watchesMovies;
  final bool likesReading;
  final bool likesOutdoorActivities;
  final bool likesParties;

  // ═══════════════════════════════════════════════════
  // PREFERENCIAS DE ROOMIE
  // ═══════════════════════════════════════════════════
  final GenderPreference preferredGender;
  final int preferredAgeMin;
  final int preferredAgeMax;
  final SmokingPreference preferredSmoker;
  final bool preferredPetFriendly;
  final PreferredNoiseLevel preferredNoiseLevel;
  final int preferredCleanlinessMin;

  // ═══════════════════════════════════════════════════
  // PRESUPUESTO (USD)
  // ═══════════════════════════════════════════════════
  final double? budgetMin;
  final double? budgetMax;

  // ═══════════════════════════════════════════════════
  // INTERESES & ESTADO
  // ═══════════════════════════════════════════════════
  final List<String> interests;
  final bool preferencesCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserPreferencesEntity({
    required this.id,
    required this.userId,
    this.isSmoker = false,
    this.drinksAlcohol = DrinksAlcohol.socially,
    this.hasPets = false,
    this.petType,
    this.sleepSchedule = SleepSchedule.flexible,
    this.workSchedule = WorkSchedule.flexible,
    this.noiseLevel = NoiseLevel.moderate,
    this.cleanlinessLevel = 3,
    this.guestsFrequency = GuestsFrequency.sometimes,
    this.exercises = false,
    this.exerciseFrequency = ExerciseFrequency.never,
    this.dietPreference = DietPreference.none,
    this.cookingFrequency = CookingFrequency.sometimes,
    this.studiesAtHome = false,
    this.worksFromHome = false,
    this.playsMusic = false,
    this.playsVideogames = false,
    this.watchesMovies = false,
    this.likesReading = false,
    this.likesOutdoorActivities = false,
    this.likesParties = false,
    this.preferredGender = GenderPreference.any,
    this.preferredAgeMin = 18,
    this.preferredAgeMax = 99,
    this.preferredSmoker = SmokingPreference.indifferent,
    this.preferredPetFriendly = true,
    this.preferredNoiseLevel = PreferredNoiseLevel.any,
    this.preferredCleanlinessMin = 1,
    this.budgetMin,
    this.budgetMax,
    this.interests = const [],
    this.preferencesCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Crear entity vacío con valores por defecto
  factory UserPreferencesEntity.empty(String userId) {
    return UserPreferencesEntity(
      id: '',
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        isSmoker,
        drinksAlcohol,
        hasPets,
        petType,
        sleepSchedule,
        workSchedule,
        noiseLevel,
        cleanlinessLevel,
        guestsFrequency,
        exercises,
        exerciseFrequency,
        dietPreference,
        cookingFrequency,
        studiesAtHome,
        worksFromHome,
        playsMusic,
        playsVideogames,
        watchesMovies,
        likesReading,
        likesOutdoorActivities,
        likesParties,
        preferredGender,
        preferredAgeMin,
        preferredAgeMax,
        preferredSmoker,
        preferredPetFriendly,
        preferredNoiseLevel,
        preferredCleanlinessMin,
        budgetMin,
        budgetMax,
        interests,
        preferencesCompleted,
      ];
}
