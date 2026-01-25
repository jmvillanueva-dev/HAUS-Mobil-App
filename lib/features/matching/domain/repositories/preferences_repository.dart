import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_preferences_entity.dart';

/// Repositorio abstracto para preferencias de usuario
abstract class PreferencesRepository {
  /// Obtener las preferencias del usuario actual
  Future<Either<Failure, UserPreferencesEntity?>> getMyPreferences();

  /// Obtener las preferencias de un usuario específico (para matching)
  Future<Either<Failure, UserPreferencesEntity?>> getUserPreferences(
      String userId);

  /// Crear o actualizar preferencias
  Future<Either<Failure, UserPreferencesEntity>> savePreferences(
      UserPreferencesEntity preferences);

  /// Eliminar preferencias del usuario actual
  Future<Either<Failure, void>> deletePreferences();

  /// Verificar si el usuario tiene preferencias completadas
  Future<Either<Failure, bool>> hasCompletedPreferences();
}
