import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_remote_datasource.dart';
import '../models/user_preferences_model.dart';

/// Implementación del repositorio de preferencias
class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesRemoteDatasource _remoteDatasource;

  PreferencesRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, UserPreferencesEntity?>> getMyPreferences() async {
    try {
      final result = await _remoteDatasource.getMyPreferences();
      return Right(result?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity?>> getUserPreferences(
      String userId) async {
    try {
      final result = await _remoteDatasource.getUserPreferences(userId);
      return Right(result?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> savePreferences(
      UserPreferencesEntity preferences) async {
    try {
      final model = UserPreferencesModel.fromEntity(preferences);

      // Verificar si ya existen preferencias
      final existing = await _remoteDatasource.getMyPreferences();

      UserPreferencesModel result;
      if (existing == null) {
        // Crear nuevas preferencias
        result = await _remoteDatasource.createPreferences(model);
      } else {
        // Actualizar preferencias existentes
        result = await _remoteDatasource.updatePreferences(model);
      }

      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePreferences() async {
    try {
      await _remoteDatasource.deletePreferences();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasCompletedPreferences() async {
    try {
      final result = await _remoteDatasource.hasPreferences();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
