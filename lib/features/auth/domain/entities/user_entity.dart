import 'package:equatable/equatable.dart';

/// Estados de verificación de identidad
enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected;

  /// Convertir desde string de base de datos
  static VerificationStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.unverified;
    }
  }

  /// Convertir a string para base de datos
  String toDbString() {
    return name;
  }
}

/// Roles de usuario
enum UserRole {
  student,
  worker;

  /// Convertir desde string de base de datos
  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'student':
        return UserRole.student;
      default:
        return UserRole.worker;
    }
  }

  /// Convertir a string para base de datos
  String toDbString() {
    return name;
  }

  /// Obtener nombre para mostrar
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Estudiante';
      case UserRole.worker:
        return 'Trabajador';
    }
  }
}

/// Entidad de usuario para HAUS
/// Sincronizada con tabla public.profiles de Supabase
class UserEntity extends Equatable {
  /// ID único (mismo que auth.users.id)
  final String id;

  /// Correo electrónico
  final String email;

  /// Nombre
  final String? firstName;

  /// Apellido
  final String? lastName;

  /// Teléfono
  final String? phone;

  /// URL de foto de perfil
  final String? avatarUrl;

  /// Biografía / descripción
  final String? bio;

  /// Rol del usuario (estudiante/trabajador)
  final UserRole role;

  /// Estado de verificación de identidad
  final VerificationStatus verificationStatus;

  /// Universidad o empresa
  final String? universityOrCompany;

  /// URL del documento de verificación
  final String? verificationDocUrl;

  /// Indica si el usuario ha seleccionado su rol explícitamente
  final bool isRoleSelected;

  /// Fecha de creación de la cuenta
  final DateTime? createdAt;

  /// Fecha de última actualización del perfil
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.role = UserRole.worker,
    this.verificationStatus = VerificationStatus.unverified,
    this.universityOrCompany,
    this.verificationDocUrl,
    this.isRoleSelected =
        true, // Por defecto true para no romper lógica existente
    this.createdAt,
    this.updatedAt,
  });

  /// Nombre completo para mostrar
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return email.split('@').first;
  }

  /// Indica si el perfil está completo (tiene nombre y apellido)
  bool get isProfileComplete {
    return firstName != null &&
        firstName!.isNotEmpty &&
        lastName != null &&
        lastName!.isNotEmpty;
  }

  /// Indica si el usuario está verificado
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  /// Indica si la verificación está pendiente
  bool get isVerificationPending =>
      verificationStatus == VerificationStatus.pending;

  /// Copia del objeto con campos modificados
  UserEntity copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? bio,
    UserRole? role,
    VerificationStatus? verificationStatus,
    String? universityOrCompany,
    String? verificationDocUrl,
    bool? isRoleSelected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      universityOrCompany: universityOrCompany ?? this.universityOrCompany,
      verificationDocUrl: verificationDocUrl ?? this.verificationDocUrl,
      isRoleSelected: isRoleSelected ?? this.isRoleSelected,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        avatarUrl,
        bio,
        role,
        verificationStatus,
        universityOrCompany,
        verificationDocUrl,
        isRoleSelected,
        createdAt,
        updatedAt,
      ];
}
