import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_location_entity.dart';

abstract class LocationRepository {
  Future<Either<Failure, List<UserLocationEntity>>> getMyLocations(
      String userId);

  Future<Either<Failure, void>> createLocation({
    required String userId,
    required LocationLabel label,
    required LocationPurpose purpose,
    String? address,
    String? city,
    String? neighborhood,
    double? latitude,
    double? longitude,
  });

  Future<Either<Failure, void>> updateLocation({
    required String locationId,
    required LocationLabel label,
    required LocationPurpose purpose,
    String? address,
    String? city,
    String? neighborhood,
    double? latitude,
    double? longitude,
  });
}
