import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_location_entity.dart';

/// Interfaz del repositorio de ubicaciones
abstract class LocationRepository {
  /// Obtener todas las ubicaciones de un usuario
  Future<Either<Failure, List<UserLocationEntity>>> getUserLocations(
      String userId);

  /// Obtener ubicaciones por propósito (search/listing)
  Future<Either<Failure, List<UserLocationEntity>>> getUserLocationsByPurpose(
    String userId,
    LocationPurpose purpose,
  );

  /// Obtener la ubicación primaria de un usuario
  Future<Either<Failure, UserLocationEntity?>> getPrimaryLocation(
      String userId);

  /// Crear una nueva ubicación
  Future<Either<Failure, UserLocationEntity>> createLocation({
    required String userId,
    required LocationLabel label,
    required LocationPurpose purpose,
    String? address,
    String? city,
    String? neighborhood,
    double? latitude,
    double? longitude,
    bool isPrimary = false,
  });

  /// Actualizar una ubicación existente
  Future<Either<Failure, UserLocationEntity>> updateLocation(
      UserLocationEntity location);

  /// Eliminar una ubicación
  Future<Either<Failure, void>> deleteLocation(String locationId);

  /// Establecer ubicación como primaria
  Future<Either<Failure, void>> setPrimaryLocation(String locationId);
}
