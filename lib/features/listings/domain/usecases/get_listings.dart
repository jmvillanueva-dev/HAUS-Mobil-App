import 'package:dartz/dartz.dart'; // <--- CAMBIO AQUÍ
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetListings implements UseCase<List<ListingEntity>, NoParams> {
  final ListingRepository repository;

  GetListings(this.repository);

  @override
  Future<Either<Failure, List<ListingEntity>>> call(NoParams params) async {
    return await repository.getListings();
  }
}