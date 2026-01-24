import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_location_entity.dart';
import '../repositories/location_repository.dart';

class GetMyLocationsUseCase {
  final LocationRepository repository;

  GetMyLocationsUseCase(this.repository);

  Future<Either<Failure, List<UserLocationEntity>>> call(String userId) async {
    return await repository.getMyLocations(userId);
  }
}
