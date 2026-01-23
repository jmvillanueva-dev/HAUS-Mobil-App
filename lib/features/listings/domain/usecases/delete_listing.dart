import 'package:dartz/dartz.dart'; // <--- CAMBIO AQUÍ
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/listing_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteListing implements UseCase<void, String> {
  final ListingRepository repository;

  DeleteListing(this.repository);

  @override
  Future<Either<Failure, void>> call(String listingId) async {
    return await repository.deleteListing(listingId);
  }
}