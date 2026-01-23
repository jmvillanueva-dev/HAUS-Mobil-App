import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Repositorio de autenticación para HAUS
abstract class AuthRepository {
  /// Iniciar sesión con email y contraseña
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registrarse con email y contraseña
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    required String role,
  });

  /// Enviar email de recuperación de contraseña
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Cerrar sesión
  Future<Either<Failure, void>> signOut();

  /// Obtener usuario actual con datos de perfil
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Obtener perfil de un usuario específico
  Future<Either<Failure, UserEntity?>> getProfile(String userId);

  /// Actualizar perfil del usuario actual
  Future<Either<Failure, void>> updateProfile(UserEntity user);

  /// Iniciar sesión con proveedor social (Google/Facebook)
  Future<Either<Failure, bool>> signInWithOAuth(dynamic provider);

  /// Actualizar metadata del usuario (auth.users)
  Future<Either<Failure, void>> updateUserMetadata(Map<String, dynamic> data);

  /// Stream de cambios en el estado de autenticación
  Stream<UserEntity?> get authStateChanges;
}
