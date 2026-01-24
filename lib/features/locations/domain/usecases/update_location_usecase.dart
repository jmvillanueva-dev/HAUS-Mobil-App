import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_location_entity.dart';
import '../repositories/location_repository.dart';

class UpdateLocationUseCase {
  final LocationRepository repository;

  UpdateLocationUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String locationId,
    required LocationLabel label,
    required LocationPurpose purpose,
    String? address,
    String? city,
    String? neighborhood,
    double? latitude,
    double? longitude,
  }) {
    return repository.updateLocation(
      locationId: locationId,
      label: label,
      purpose: purpose,
      address: address,
      city: city,
      neighborhood: neighborhood,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
