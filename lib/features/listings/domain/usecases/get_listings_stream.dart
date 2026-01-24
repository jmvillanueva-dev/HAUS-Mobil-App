import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetListingsStream {
  final ListingRepository repository;

  GetListingsStream(this.repository);

  Stream<Either<Failure, List<ListingEntity>>> call(NoParams params) {
    return repository.getListingsStream();
  }
}
