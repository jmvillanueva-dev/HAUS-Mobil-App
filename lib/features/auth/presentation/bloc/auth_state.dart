import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class ResetPasswordSent extends AuthState {
  const ResetPasswordSent();
}

class EmailVerificationRequired extends AuthState {
  final String email;

  const EmailVerificationRequired(this.email);

  @override
  List<Object> get props => [email];
}

/// Estado emitido cuando el perfil se actualiza exitosamente
class ProfileUpdated extends AuthState {
  final UserEntity user;

  const ProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

/// Estado emitido cuando se está actualizando el perfil
class ProfileUpdateLoading extends AuthState {
  const ProfileUpdateLoading();
}

/// Estado emitido cuando se requiere completar el onboarding
class OnboardingRequired extends AuthState {
  final UserEntity user;

  const OnboardingRequired(this.user);

  @override
  List<Object> get props => [user];
}
