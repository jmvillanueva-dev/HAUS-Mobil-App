import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';
import '../models/user_location_model.dart';

@LazySingleton(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<UserLocationEntity>>> getUserLocations(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }

    try {
      final locations = await remoteDataSource.getUserLocations(userId);
      return Right(locations.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserLocationEntity>>> getUserLocationsByPurpose(
    String userId,
    LocationPurpose purpose,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }

    try {
      final locations = await remoteDataSource.getUserLocationsByPurpose(
        userId,
        purpose,
      );
      return Right(locations.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserLocationEntity?>> getPrimaryLocation(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }

    try {
      final location = await remoteDataSource.getPrimaryLocation(userId);
      return Right(location?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }

    try {
      final now = DateTime.now();
      final locationModel = UserLocationModel(
        id: '', // Se genera en BD
        userId: userId,
        label: label,
        purpose: purpose,
        address: address,
        city: city,
        neighborhood: neighborhood,
        latitude: latitude,
        longitude: longitude,
        isPrimary: isPrimary,
        createdAt: now,
        updatedAt: now,
      );

      final created = await remoteDataSource.createLocation(locationModel);
      return Right(created.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserLocationEntity>> updateLocation(
    UserLocationEntity location,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }

    try {
      final locationModel = UserLocationModel.fromEntity(location);
      final updated = await remoteDataSource.updateLocation(locationModel);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocation(String locationId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }

    try {
      await remoteDataSource.deleteLocation(locationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPrimaryLocation(String locationId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }

    try {
      await remoteDataSource.setPrimaryLocation(locationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
