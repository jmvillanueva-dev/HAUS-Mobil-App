import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetMyListingsStream {
  final ListingRepository repository;

  GetMyListingsStream(this.repository);

  Stream<Either<Failure, List<ListingEntity>>> call(String userId) {
    return repository.getMyListingsStream(userId);
  }
}
