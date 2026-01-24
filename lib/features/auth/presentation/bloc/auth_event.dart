import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento de inicio de sesión
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Evento de registro con nombre y apellido separados
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String role;

  const SignUpRequested({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    required this.role,
  });

  /// Nombre completo para compatibilidad
  String? get displayName {
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return null;
  }

  @override
  List<Object?> get props => [email, password, firstName, lastName, role];
}

/// Evento de solicitud de restablecimiento de contraseña
class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Evento de cierre de sesión
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Evento para verificar estado de autenticación
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento para actualizar perfil
class UpdateProfileRequested extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? bio;
  final String? universityOrCompany;
  final String? avatarUrl;
  final bool? onboardingCompleted;

  const UpdateProfileRequested({
    this.firstName,
    this.lastName,
    this.phone,
    this.bio,
    this.universityOrCompany,
    this.avatarUrl,
    this.onboardingCompleted,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        phone,
        bio,
        universityOrCompany,
        avatarUrl,
        onboardingCompleted
      ];
}

/// Evento de inicio de sesión social
class SocialSignInRequested extends AuthEvent {
  final dynamic provider; // OAuthProvider

  const SocialSignInRequested(this.provider);

  @override
  List<Object> get props => [provider];
}

/// Evento de selección de rol post-login social
class RoleSelected extends AuthEvent {
  final String role;

  const RoleSelected(this.role);

  @override
  List<Object> get props => [role];
}
