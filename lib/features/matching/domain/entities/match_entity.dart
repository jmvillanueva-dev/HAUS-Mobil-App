import 'package:equatable/equatable.dart';

/// Tipos de interacción de usuario
enum InteractionType { like, skip, superLike }

extension InteractionTypeX on InteractionType {
  String toDbString() {
    switch (this) {
      case InteractionType.like:
        return 'like';
      case InteractionType.skip:
        return 'skip';
      case InteractionType.superLike:
        return 'super_like';
    }
  }

  static InteractionType fromString(String? value) {
    switch (value) {
      case 'like':
        return InteractionType.like;
      case 'skip':
        return InteractionType.skip;
      case 'super_like':
        return InteractionType.superLike;
      default:
        return InteractionType.skip;
    }
  }
}

/// Representa una interacción (like/skip) entre usuarios
class UserInteraction extends Equatable {
  final String id;
  final String userId;
  final String targetUserId;
  final InteractionType action;
  final DateTime createdAt;

  const UserInteraction({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.action,
    required this.createdAt,
  });

  factory UserInteraction.fromJson(Map<String, dynamic> json) {
    return UserInteraction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetUserId: json['target_user_id'] as String,
      action: InteractionTypeX.fromString(json['action'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'target_user_id': targetUserId,
        'action': action.toDbString(),
      };

  @override
  List<Object?> get props => [id, userId, targetUserId, action, createdAt];
}

/// Representa un match mutuo entre dos usuarios
class Match extends Equatable {
  final String id;
  final String userAId;
  final String userBId;
  final double compatibilityScore;
  final String? conversationId;
  final bool isActive;
  final DateTime matchedAt;

  // Datos del otro usuario (para mostrar en UI)
  final MatchCandidate? otherUser;

  const Match({
    required this.id,
    required this.userAId,
    required this.userBId,
    required this.compatibilityScore,
    this.conversationId,
    this.isActive = true,
    required this.matchedAt,
    this.otherUser,
  });

  factory Match.fromJson(Map<String, dynamic> json,
      {MatchCandidate? otherUser}) {
    return Match(
      id: json['id'] as String,
      userAId: json['user_a'] as String,
      userBId: json['user_b'] as String,
      compatibilityScore:
          (json['compatibility_score'] as num?)?.toDouble() ?? 0,
      conversationId: json['conversation_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      matchedAt: DateTime.parse(json['matched_at'] as String),
      otherUser: otherUser,
    );
  }

  /// Obtiene el ID del otro usuario en el match
  String getOtherUserId(String currentUserId) {
    return userAId == currentUserId ? userBId : userAId;
  }

  @override
  List<Object?> get props => [
        id,
        userAId,
        userBId,
        compatibilityScore,
        conversationId,
        isActive,
        matchedAt,
      ];
}

/// Representa un candidato para matching (usuario con su score)
class MatchCandidate extends Equatable {
  final String userId;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? bio;
  final String? role;
  final double compatibilityScore;

  // Datos adicionales de preferencias
  final double? budgetMin;
  final double? budgetMax;
  final int? cleanlinessLevel;
  final String? sleepSchedule;
  final String? noiseLevel;
  final bool? isSmoker;
  final bool? hasPets;
  final bool? exercises;
  final bool? playsVideogames;
  final bool? playsMusic;
  final bool? worksFromHome;
  final bool? likesParties;
  final List<String>? interests;

  const MatchCandidate({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.bio,
    this.role,
    required this.compatibilityScore,
    this.budgetMin,
    this.budgetMax,
    this.cleanlinessLevel,
    this.sleepSchedule,
    this.noiseLevel,
    this.isSmoker,
    this.hasPets,
    this.exercises,
    this.playsVideogames,
    this.playsMusic,
    this.worksFromHome,
    this.likesParties,
    this.interests,
  });

  String get displayName => '$firstName $lastName'.trim();

  factory MatchCandidate.fromJson(Map<String, dynamic> json) {
    return MatchCandidate(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String?,
      compatibilityScore:
          (json['compatibility_score'] as num?)?.toDouble() ?? 0,
      budgetMin: (json['budget_min'] as num?)?.toDouble(),
      budgetMax: (json['budget_max'] as num?)?.toDouble(),
      cleanlinessLevel: json['cleanliness_level'] as int?,
      sleepSchedule: json['sleep_schedule'] as String?,
      noiseLevel: json['noise_level'] as String?,
      isSmoker: json['is_smoker'] as bool?,
      hasPets: json['has_pets'] as bool?,
      exercises: json['exercises'] as bool?,
      playsVideogames: json['plays_videogames'] as bool?,
      playsMusic: json['plays_music'] as bool?,
      worksFromHome: json['works_from_home'] as bool?,
      likesParties: json['likes_parties'] as bool?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Genera chips de características para mostrar en UI
  List<String> getCharacteristicChips() {
    final chips = <String>[];

    if (exercises == true) chips.add('🏃 Ejercicio');
    if (playsVideogames == true) chips.add('🎮 Gamer');
    if (playsMusic == true) chips.add('🎵 Música');
    if (worksFromHome == true) chips.add('💻 Remoto');
    if (likesParties == true) chips.add('🎉 Fiestas');
    if (hasPets == true) chips.add('🐾 Mascotas');

    if (sleepSchedule == 'early_bird') chips.add('🌅 Madrugador');
    if (sleepSchedule == 'night_owl') chips.add('🦉 Nocturno');

    if (noiseLevel == 'quiet') chips.add('🤫 Tranquilo');
    if (noiseLevel == 'social') chips.add('🗣️ Social');

    return chips.take(5).toList(); // Máximo 5 chips
  }

  @override
  List<Object?> get props => [userId, firstName, lastName, compatibilityScore];
}
