import '../../domain/entities/user_preferences_entity.dart';

/// Modelo de datos para preferencias de usuario
/// Maneja la conversión entre Supabase y UserPreferencesEntity
class UserPreferencesModel extends UserPreferencesEntity {
  const UserPreferencesModel({
    required super.id,
    required super.userId,
    super.isSmoker,
    super.drinksAlcohol,
    super.hasPets,
    super.petType,
    super.sleepSchedule,
    super.workSchedule,
    super.noiseLevel,
    super.cleanlinessLevel,
    super.guestsFrequency,
    super.exercises,
    super.exerciseFrequency,
    super.dietPreference,
    super.cookingFrequency,
    super.studiesAtHome,
    super.worksFromHome,
    super.playsMusic,
    super.playsVideogames,
    super.watchesMovies,
    super.likesReading,
    super.likesOutdoorActivities,
    super.likesParties,
    super.preferredGender,
    super.preferredAgeMin,
    super.preferredAgeMax,
    super.preferredSmoker,
    super.preferredPetFriendly,
    super.preferredNoiseLevel,
    super.preferredCleanlinessMin,
    super.budgetMin,
    super.budgetMax,
    super.interests,
    super.preferencesCompleted,
    super.createdAt,
    super.updatedAt,
  });

  /// Crear desde JSON de Supabase
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      // Hábitos personales
      isSmoker: json['is_smoker'] as bool? ?? false,
      drinksAlcohol:
          DrinksAlcoholX.fromString(json['drinks_alcohol'] as String?),
      hasPets: json['has_pets'] as bool? ?? false,
      petType: json['pet_type'] as String?,
      // Estilo de vida
      sleepSchedule:
          SleepScheduleX.fromString(json['sleep_schedule'] as String?),
      workSchedule: WorkScheduleX.fromString(json['work_schedule'] as String?),
      noiseLevel: NoiseLevelX.fromString(json['noise_level'] as String?),
      cleanlinessLevel: json['cleanliness_level'] as int? ?? 3,
      guestsFrequency:
          GuestsFrequencyX.fromString(json['guests_frequency'] as String?),
      // Actividades
      exercises: json['exercises'] as bool? ?? false,
      exerciseFrequency:
          ExerciseFrequencyX.fromString(json['exercise_frequency'] as String?),
      dietPreference:
          DietPreferenceX.fromString(json['diet_preference'] as String?),
      cookingFrequency:
          CookingFrequencyX.fromString(json['cooking_frequency'] as String?),
      studiesAtHome: json['studies_at_home'] as bool? ?? false,
      worksFromHome: json['works_from_home'] as bool? ?? false,
      playsMusic: json['plays_music'] as bool? ?? false,
      playsVideogames: json['plays_videogames'] as bool? ?? false,
      watchesMovies: json['watches_movies'] as bool? ?? false,
      likesReading: json['likes_reading'] as bool? ?? false,
      likesOutdoorActivities:
          json['likes_outdoor_activities'] as bool? ?? false,
      likesParties: json['likes_parties'] as bool? ?? false,
      // Preferencias de roomie
      preferredGender:
          GenderPreferenceX.fromString(json['preferred_gender'] as String?),
      preferredAgeMin: json['preferred_age_min'] as int? ?? 18,
      preferredAgeMax: json['preferred_age_max'] as int? ?? 99,
      preferredSmoker:
          SmokingPreferenceX.fromString(json['preferred_smoker'] as String?),
      preferredPetFriendly: json['preferred_pet_friendly'] as bool? ?? true,
      preferredNoiseLevel: PreferredNoiseLevelX.fromString(
          json['preferred_noise_level'] as String?),
      preferredCleanlinessMin: json['preferred_cleanliness_min'] as int? ?? 1,
      // Presupuesto
      budgetMin: (json['budget_min'] as num?)?.toDouble(),
      budgetMax: (json['budget_max'] as num?)?.toDouble(),
      // Intereses
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      preferencesCompleted: json['preferences_completed'] as bool? ?? false,
      // Timestamps
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convertir a JSON para guardar en Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      // Hábitos personales
      'is_smoker': isSmoker,
      'drinks_alcohol': drinksAlcohol.toDbString(),
      'has_pets': hasPets,
      'pet_type': petType,
      // Estilo de vida
      'sleep_schedule': sleepSchedule.toDbString(),
      'work_schedule': workSchedule.toDbString(),
      'noise_level': noiseLevel.toDbString(),
      'cleanliness_level': cleanlinessLevel,
      'guests_frequency': guestsFrequency.toDbString(),
      // Actividades
      'exercises': exercises,
      'exercise_frequency': exerciseFrequency.toDbString(),
      'diet_preference': dietPreference.toDbString(),
      'cooking_frequency': cookingFrequency.toDbString(),
      'studies_at_home': studiesAtHome,
      'works_from_home': worksFromHome,
      'plays_music': playsMusic,
      'plays_videogames': playsVideogames,
      'watches_movies': watchesMovies,
      'likes_reading': likesReading,
      'likes_outdoor_activities': likesOutdoorActivities,
      'likes_parties': likesParties,
      // Preferencias de roomie
      'preferred_gender': preferredGender.toDbString(),
      'preferred_age_min': preferredAgeMin,
      'preferred_age_max': preferredAgeMax,
      'preferred_smoker': preferredSmoker.toDbString(),
      'preferred_pet_friendly': preferredPetFriendly,
      'preferred_noise_level': preferredNoiseLevel.toDbString(),
      'preferred_cleanliness_min': preferredCleanlinessMin,
      // Presupuesto
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      // Intereses
      'interests': interests,
      'preferences_completed': preferencesCompleted,
    };
  }

  /// Convertir a Entity puro
  UserPreferencesEntity toEntity() {
    return UserPreferencesEntity(
      id: id,
      userId: userId,
      isSmoker: isSmoker,
      drinksAlcohol: drinksAlcohol,
      hasPets: hasPets,
      petType: petType,
      sleepSchedule: sleepSchedule,
      workSchedule: workSchedule,
      noiseLevel: noiseLevel,
      cleanlinessLevel: cleanlinessLevel,
      guestsFrequency: guestsFrequency,
      exercises: exercises,
      exerciseFrequency: exerciseFrequency,
      dietPreference: dietPreference,
      cookingFrequency: cookingFrequency,
      studiesAtHome: studiesAtHome,
      worksFromHome: worksFromHome,
      playsMusic: playsMusic,
      playsVideogames: playsVideogames,
      watchesMovies: watchesMovies,
      likesReading: likesReading,
      likesOutdoorActivities: likesOutdoorActivities,
      likesParties: likesParties,
      preferredGender: preferredGender,
      preferredAgeMin: preferredAgeMin,
      preferredAgeMax: preferredAgeMax,
      preferredSmoker: preferredSmoker,
      preferredPetFriendly: preferredPetFriendly,
      preferredNoiseLevel: preferredNoiseLevel,
      preferredCleanlinessMin: preferredCleanlinessMin,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      interests: interests,
      preferencesCompleted: preferencesCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crear desde Entity
  factory UserPreferencesModel.fromEntity(UserPreferencesEntity entity) {
    return UserPreferencesModel(
      id: entity.id,
      userId: entity.userId,
      isSmoker: entity.isSmoker,
      drinksAlcohol: entity.drinksAlcohol,
      hasPets: entity.hasPets,
      petType: entity.petType,
      sleepSchedule: entity.sleepSchedule,
      workSchedule: entity.workSchedule,
      noiseLevel: entity.noiseLevel,
      cleanlinessLevel: entity.cleanlinessLevel,
      guestsFrequency: entity.guestsFrequency,
      exercises: entity.exercises,
      exerciseFrequency: entity.exerciseFrequency,
      dietPreference: entity.dietPreference,
      cookingFrequency: entity.cookingFrequency,
      studiesAtHome: entity.studiesAtHome,
      worksFromHome: entity.worksFromHome,
      playsMusic: entity.playsMusic,
      playsVideogames: entity.playsVideogames,
      watchesMovies: entity.watchesMovies,
      likesReading: entity.likesReading,
      likesOutdoorActivities: entity.likesOutdoorActivities,
      likesParties: entity.likesParties,
      preferredGender: entity.preferredGender,
      preferredAgeMin: entity.preferredAgeMin,
      preferredAgeMax: entity.preferredAgeMax,
      preferredSmoker: entity.preferredSmoker,
      preferredPetFriendly: entity.preferredPetFriendly,
      preferredNoiseLevel: entity.preferredNoiseLevel,
      preferredCleanlinessMin: entity.preferredCleanlinessMin,
      budgetMin: entity.budgetMin,
      budgetMax: entity.budgetMax,
      interests: entity.interests,
      preferencesCompleted: entity.preferencesCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crear copia con cambios
  UserPreferencesModel copyWith({
    String? id,
    String? userId,
    bool? isSmoker,
    DrinksAlcohol? drinksAlcohol,
    bool? hasPets,
    String? petType,
    SleepSchedule? sleepSchedule,
    WorkSchedule? workSchedule,
    NoiseLevel? noiseLevel,
    int? cleanlinessLevel,
    GuestsFrequency? guestsFrequency,
    bool? exercises,
    ExerciseFrequency? exerciseFrequency,
    DietPreference? dietPreference,
    CookingFrequency? cookingFrequency,
    bool? studiesAtHome,
    bool? worksFromHome,
    bool? playsMusic,
    bool? playsVideogames,
    bool? watchesMovies,
    bool? likesReading,
    bool? likesOutdoorActivities,
    bool? likesParties,
    GenderPreference? preferredGender,
    int? preferredAgeMin,
    int? preferredAgeMax,
    SmokingPreference? preferredSmoker,
    bool? preferredPetFriendly,
    PreferredNoiseLevel? preferredNoiseLevel,
    int? preferredCleanlinessMin,
    double? budgetMin,
    double? budgetMax,
    List<String>? interests,
    bool? preferencesCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferencesModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isSmoker: isSmoker ?? this.isSmoker,
      drinksAlcohol: drinksAlcohol ?? this.drinksAlcohol,
      hasPets: hasPets ?? this.hasPets,
      petType: petType ?? this.petType,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      workSchedule: workSchedule ?? this.workSchedule,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      cleanlinessLevel: cleanlinessLevel ?? this.cleanlinessLevel,
      guestsFrequency: guestsFrequency ?? this.guestsFrequency,
      exercises: exercises ?? this.exercises,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      dietPreference: dietPreference ?? this.dietPreference,
      cookingFrequency: cookingFrequency ?? this.cookingFrequency,
      studiesAtHome: studiesAtHome ?? this.studiesAtHome,
      worksFromHome: worksFromHome ?? this.worksFromHome,
      playsMusic: playsMusic ?? this.playsMusic,
      playsVideogames: playsVideogames ?? this.playsVideogames,
      watchesMovies: watchesMovies ?? this.watchesMovies,
      likesReading: likesReading ?? this.likesReading,
      likesOutdoorActivities:
          likesOutdoorActivities ?? this.likesOutdoorActivities,
      likesParties: likesParties ?? this.likesParties,
      preferredGender: preferredGender ?? this.preferredGender,
      preferredAgeMin: preferredAgeMin ?? this.preferredAgeMin,
      preferredAgeMax: preferredAgeMax ?? this.preferredAgeMax,
      preferredSmoker: preferredSmoker ?? this.preferredSmoker,
      preferredPetFriendly: preferredPetFriendly ?? this.preferredPetFriendly,
      preferredNoiseLevel: preferredNoiseLevel ?? this.preferredNoiseLevel,
      preferredCleanlinessMin:
          preferredCleanlinessMin ?? this.preferredCleanlinessMin,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      interests: interests ?? this.interests,
      preferencesCompleted: preferencesCompleted ?? this.preferencesCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
