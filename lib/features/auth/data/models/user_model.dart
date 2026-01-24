import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

/// Modelo de datos de usuario para HAUS
/// Maneja la conversión entre Supabase y UserEntity
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.firstName,
    super.lastName,
    super.phone,
    super.avatarUrl,
    super.bio,
    super.role,
    super.verificationStatus,
    super.universityOrCompany,
    super.verificationDocUrl,
    super.isRoleSelected,
    super.onboardingCompleted,
    super.createdAt,
    super.updatedAt,
  });

  /// Crear desde usuario de Supabase Auth (auth.users)
  /// Solo contiene datos básicos del registro
  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};

    // Intentar obtener nombre completo y dividirlo
    final displayName = metadata['display_name'] as String?;
    String? firstName;
    String? lastName;

    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(' ');
      firstName = parts.isNotEmpty ? parts.first : null;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
    }

    // También intentar obtener first_name y last_name directamente si existen
    firstName = metadata['first_name'] as String? ?? firstName;
    lastName = metadata['last_name'] as String? ?? lastName;

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      firstName: firstName,
      lastName: lastName,
      phone: metadata['phone'] as String?,
      avatarUrl: metadata['avatar_url'] as String?,
      role: UserRole.fromString(metadata['role'] as String?),
      isRoleSelected:
          metadata.containsKey('role') || metadata.containsKey('role_selected'),
      onboardingCompleted: false, // Desde auth no tenemos este dato
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  /// Crear desde datos de la tabla profiles (public.profiles)
  /// Contiene datos completos del perfil
  factory UserModel.fromProfileJson(Map<String, dynamic> json,
      {String? email}) {
    return UserModel(
      id: json['id'] as String,
      email: email ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      verificationStatus:
          VerificationStatus.fromString(json['status'] as String?),
      universityOrCompany: json['university_or_company'] as String?,
      verificationDocUrl: json['verification_doc_url'] as String?,
      // Si solo tenemos el perfil, asumimos que el rol es válido,
      // pero idealmente siempre deberíamos tener el usuario de auth.
      isRoleSelected: true,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Combinar datos de Auth user con datos de Profile
  factory UserModel.fromAuthAndProfile(
      User authUser, Map<String, dynamic>? profile) {
    if (profile == null) {
      return UserModel.fromSupabaseUser(authUser);
    }

    final metadata = authUser.userMetadata ?? {};

    return UserModel(
      id: authUser.id,
      email: authUser.email ?? '',
      firstName: profile['first_name'] as String?,
      lastName: profile['last_name'] as String?,
      phone: profile['phone'] as String?,
      avatarUrl: profile['avatar_url'] as String?,
      bio: profile['bio'] as String?,
      role: UserRole.fromString(profile['role'] as String?),
      verificationStatus:
          VerificationStatus.fromString(profile['status'] as String?),
      universityOrCompany: profile['university_or_company'] as String?,
      verificationDocUrl: profile['verification_doc_url'] as String?,
      isRoleSelected:
          metadata.containsKey('role') || metadata.containsKey('role_selected'),
      onboardingCompleted: profile['onboarding_completed'] as bool? ?? false,
      createdAt: DateTime.tryParse(authUser.createdAt),
      updatedAt: profile['updated_at'] != null
          ? DateTime.tryParse(profile['updated_at'] as String)
          : null,
    );
  }

  /// Convertir a mapa JSON para guardar/actualizar en profiles
  Map<String, dynamic> toProfileJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'role': role.toDbString(),
      'university_or_company': universityOrCompany,
      'onboarding_completed': onboardingCompleted,
      // status y verification_doc_url no se actualizan desde el cliente
    };
  }

  /// Convertir a mapa para actualización parcial del perfil
  Map<String, dynamic> toProfileUpdateJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['first_name'] = firstName;
    if (lastName != null) map['last_name'] = lastName;
    if (phone != null) map['phone'] = phone;
    if (avatarUrl != null) map['avatar_url'] = avatarUrl;
    if (bio != null) map['bio'] = bio;
    if (universityOrCompany != null) {
      map['university_or_company'] = universityOrCompany;
    }
    // Siempre incluir onboarding_completed cuando es true
    if (onboardingCompleted) {
      map['onboarding_completed'] = true;
    }
    return map;
  }

  /// Convertir a UserEntity puro
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatarUrl: avatarUrl,
      bio: bio,
      role: role,
      verificationStatus: verificationStatus,
      universityOrCompany: universityOrCompany,
      verificationDocUrl: verificationDocUrl,
      isRoleSelected: isRoleSelected,
      onboardingCompleted: onboardingCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crear UserModel desde UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      bio: entity.bio,
      role: entity.role,
      verificationStatus: entity.verificationStatus,
      universityOrCompany: entity.universityOrCompany,
      verificationDocUrl: entity.verificationDocUrl,
      isRoleSelected: entity.isRoleSelected,
      onboardingCompleted: entity.onboardingCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
